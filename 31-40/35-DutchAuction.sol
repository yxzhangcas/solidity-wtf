// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "31-40/34-ERC721.sol";

// 这里的ERC721是一个标准实现，不只是接口
contract DutchAuction is Ownable, ERC721Impl {

    uint256 public constant COLLECTION_SIZE = 10000;            // NFT总数
    uint256 public constant AUCTION_START_PRICE = 1 ether;      // 起拍价（最高价）
    uint256 public constant AUCTION_END_PRICE = 0.1 ether;      // 结束价（最低价/地板价）
    uint256 public constant AUCTION_TIME = 10 minutes;          // 拍卖时间
    uint256 public constant AUCTION_DROP_INTERVAL = 1 minutes;  // 价格衰减周期
    uint256 public constant AUCTION_DROP_PER_STEP = (AUCTION_START_PRICE - AUCTION_END_PRICE) / (AUCTION_TIME / AUCTION_DROP_INTERVAL);     // 价格衰减步长

    uint256 public auctionStartTime;        // 拍卖开始时间戳
 
    string private _baseTokenURI;           // metadata URI
    uint256[] private _allTokens;           // 所有存在的tokenId

    // ?没有调用Ownable的构造函数?
    constructor() ERC721Impl("Dutch Auction", "Dutch Auction") Ownable(msg.sender) {
        auctionStartTime = block.timestamp;
    }

    // 设置拍卖起始时间，用onlyOwner进行约束
    function setAuctionStartTime(uint32 timestamp) external onlyOwner {
        auctionStartTime = timestamp;
    }

    // 获取拍卖实时价格
    function getAuctionPrice() public view returns (uint256) {
        if (block.timestamp < auctionStartTime) {
            return AUCTION_START_PRICE;
        } else if (block.timestamp - auctionStartTime >= AUCTION_TIME) {
            return AUCTION_END_PRICE;
        } else {
            uint256 steps = (block.timestamp - auctionStartTime) / AUCTION_DROP_INTERVAL;
            return AUCTION_START_PRICE - (steps * AUCTION_DROP_PER_STEP);
        }
    }

    // 拍卖铸造NFT
    function auctionMint(uint256 quantity) external payable {
        uint256 _saleStartTime = uint256(auctionStartTime);         // local变量，节省gas
        require(_saleStartTime != 0 && block.timestamp >= _saleStartTime, "sale has not started yet");      // 是否设置起拍时间，拍卖是否开始
        require(totalSupply() + quantity <= COLLECTION_SIZE, "not enough remaining reserved for auction to support desired mint amount");   // 是否超过NFT上限

        uint256 totalCost = getAuctionPrice() * quantity;               // 计算mint成本
        require(msg.value >= totalCost, "Need to send more ETH.");      // 检查是否足够支付ETH

        // mint NFT
        for (uint256 i = 0; i < quantity; i++) {
            uint256 mintIndex = totalSupply();
            _mint(msg.sender, mintIndex);               // 铸造n个NFT：拍卖用于铸造NFT，然后就可以继续常规NFT交易了
            _addTokenToAllTokensEnumeration(mintIndex);
        }

        // 多余ETH退款
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);        // 注意检查重入风险
        }
    }

    // 提款
    function withdrawMoney() external onlyOwner {
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }


    function totalSupply() public view virtual returns (uint256) {
        return _allTokens.length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokens.push(tokenId);
    }
}