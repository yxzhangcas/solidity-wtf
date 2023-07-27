// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTSwap is IERC721Receiver {
    event List(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 price);
    event Purchase(address indexed buyer, address indexed nftAddr, uint256 indexed tokenId, uint256 price);
    event Revoke(address indexed seller, address indexed nftAddr, uint256 indexed tokenId);
    event Update(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 newPrice);
    event Check(address operator, address from, uint tokenId, bytes data);

    struct Order {
        address owner;
        uint256 price;
    }
    mapping(address => mapping(uint256 => Order)) public nftList;

    fallback() external payable {}
    receive() external payable {}

    function onERC721Received(address operator, address from, uint tokenId, bytes calldata data) external override returns (bytes4) {
        emit Check(operator, from, tokenId, data);
        return IERC721Receiver.onERC721Received.selector;
    }

    // 卖家挂单
    function list(address _nftAddr, uint256 _tokenId, uint256 _price) public {
        // 对应NFT是否授权本合约进行处理
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.getApproved(_tokenId) == address(this), "Need Approval");
        require(_price > 0);
        // 记录此NFT对应的合约/ID所实际归属的卖家和挂单价到状态中
        Order storage _order = nftList[_nftAddr][_tokenId];
        _order.owner = msg.sender;
        _order.price = _price;
        // 将NFT所有权从卖家转给合约（此时权属关系已经发生变化）
        _nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        emit List(msg.sender, _nftAddr, _tokenId, _price);
    }
    // 卖家撤单
    function revoke(address _nftAddr, uint256 _tokenId) public {
        // NFT对应的Token在属于卖家
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.owner == msg.sender, "Not Owner");
        // NFT对应的Token在NFT合约中属于此合约
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order");
        // NFT所有权从合约转回卖家
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        // 删除挂单状态
        delete nftList[_nftAddr][_tokenId];

        emit Revoke(msg.sender, _nftAddr, _tokenId);
    }
    // 卖家改价
    function update(address _nftAddr, uint256 _tokenId, uint256 _newPrice) public {
        require(_newPrice > 0, "Invalid Price");
        // NFT对应的Token属于卖家
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.owner == msg.sender, "Not Owner");
        // NFT对应的Token在NFT合约中属于此合约
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Owner");
        // 改价
        _order.price = _newPrice;

        emit Update(msg.sender, _nftAddr, _tokenId, _newPrice);
    }
    // 买家购买
    function purchase(address _nftAddr, uint256 _tokenId) payable public {
        // 验资
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.price > 0, "Invalid Price");
        require(msg.value >= _order.price, "Increase price");
        // NFT对应的Token在NFT合约中属于此合约
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order");
        // NFT在NFT合约中转给买家（交易）
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        // 将ETH转给卖家，并退找零
        payable(_order.owner).transfer(_order.price);
        payable(msg.sender).transfer(msg.value - _order.price);
        // 删除挂单状态（买家只进行了购买，并未挂单）
        delete nftList[_nftAddr][_tokenId];

        emit Purchase(msg.sender, _nftAddr, _tokenId, msg.value);
    }
}


// 1.部署WTFApe合约
// 2.挖一个NFT给自己的地址，检查NFT的持有者是否正确
// 3.部署NFTSwap合约
// 4.调用WTFApe合约的approve，将自己的NFT授权给NFTSwap合约
// 5.挂单NFT
// 6.改价NFT
// 7.撤单NFT
// 8.授权NFT给NFTSwap合约
// 9.挂单NFT
// 10.切换账号购买NFT
// 11.验证NFT的所有权变更