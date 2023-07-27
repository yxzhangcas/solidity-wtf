// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// ERC721 非同质化物品
// 利用tokenId表示特定的非同质化代币，授权转账等操作都要明确tokenId，而ERC20只需要明确数额
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";

// ERC165
// https://eips.ethereum.org/EIPS/eip-165
// 声明合约支持的接口
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/IERC165.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";

// IERC165: 1个函数(1查询)，合约支持的接口类型ID，用于其它合约进行检查。 https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified
// IERC721(继承IERC165): 3个event，9个函数(4查询,5操作)。
// IERC721Metadata(继承IERC721)：3个方法(3查询)。

// IERC721Receiver：1个函数。
// 为了防止误转账，ERC721实现了safeTransferFrom()安全转账函数，目标合约必须实现了IERC721Receiver接口才能接收ERC721代币，不然会revert。
contract ERC721Impl is IERC721, IERC721Metadata {

    using Address for address;  // lib库
    using Strings for uint256;  // lib库

    // 构造时初始化(IERC721Metadata)
    string public override name;    // token名称
    string public override symbol;  // token代号

    mapping(uint => address) private _owners;           // tokenId到持有人地址映射
    mapping(address => uint) private _balances;         // address到持仓数量映射
    mapping(uint => address) private _tokenApprovals;   // tokenId到授权地址映射
    mapping(address => mapping(address => bool)) private _operatorApprovals;    // owner到operator地址的批量授权映射

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    // [查询]实现IERC165接口方法
    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return 
            interfaceId == type(IERC721).interfaceId || 
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId;
    }

    // [查询]实现IERC721接口的balanceOf，利用_balances查询owner的balance
    function balanceOf(address owner) external view override returns (uint) {
        require(owner != address(0), "owner = zero address");
        return _balances[owner];
    }

    // [查询]实现IERC721接口的ownerOf，利用_owners查询tokenId的owner
    function ownerOf(uint tokenId) public view override returns (address owner) {
        owner = _owners[tokenId];
        require(owner != address(0), "token doesn't exist");
    }

    // [查询]实现IERC721接口的isApprovedForAll，利用_operatorApprovals查询owner地址是否批量授权operator地址
    function isApprovedForAll(address owner, address operator) external view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // 实现IERC721接口的setApprovalForAll，调用者将持有token全部授权给operation地址
    function setApprovalForAll(address operator, bool approved) external override {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // [查询]实现IERC721接口的getApproved，利用_tokenApprovals查询tokenId的授权地址
    function getApproved(uint tokenId) external view override returns (address) {
        require(_owners[tokenId] != address(0), "token does't exist");
        return _tokenApprovals[tokenId];
    }

    // 授权函数，修改_tokenApprovals，授权to地址操作tokenId
    function _approve(address owner, address to, uint tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    // 实现IERC721的approval，将tokenId授权给to地址
    function approve(address to, uint tokenId) external override {
        address owner = _owners[tokenId];
        require(msg.sender == owner || _operatorApprovals[owner][msg.sender], "not owner or approved for all");
        _approve(owner, to, tokenId);
    }

    // 查询spender地址是否可以使用tokenId
    function _isApprovedOrOwner(address owner, address spender, uint tokenId) private view returns (bool) {
        return spender == owner || _tokenApprovals[tokenId] == spender || _operatorApprovals[owner][spender];
    }

    // 转账函数，调整_balances和_owner将tokenId从from转给to
    function _transfer(address owner, address from, address to, uint tokenId) private {
        require(from == owner, "not owner");
        require(to != address(0), "transfer to zero address");

        _approve(owner, address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    // 实现IERC721的transferFrom，非安全转账，不建议使用
    function transferFrom(address from, address to, uint tokenId) external override {
        address owner = ownerOf(tokenId);
        require(_isApprovedOrOwner(owner, msg.sender, tokenId), "not owner or approved");
        _transfer(owner, from, to, tokenId);
    }

    // 防止tokenId被转入黑洞，检查目标合约的接口
    function _checkOnERC721Received(address from, address to, uint tokenId, bytes memory _data) private returns (bool) {
        // 此函数已经去掉了：https://github.com/OpenZeppelin/openzeppelin-contracts/commit/c5d040beb9a951b00e9cb57c4e7dd97cd04b45ac
        // if (to.isContract()) {
        // 改用方法：_address.code.length > 0 进行判断
        if (to.code.length > 0) {
            // 目标合约必须实现IERC721Receiver接口才能转账
            return IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) == IERC721Receiver.onERC721Received.selector;
        } else {
            return true;
        }
    }

    // 安全转账
    function _safeTransfer(address owner, address from, address to, uint tokenId, bytes memory _data) private {
        _transfer(owner, from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "not ERC721Receiver");
    }

    // 实现IERC721的safeTransferFrom，安全转账
    function safeTransferFrom(address from, address to, uint tokenId, bytes memory _data) public override {
        address owner = ownerOf(tokenId);
        require(_isApprovedOrOwner(owner, msg.sender, tokenId), "not owner or approved");
        _safeTransfer(owner, from, to, tokenId, _data);
    }

    //  实现IERC721的safeTransferFrom重载
    function safeTransferFrom(address from, address to, uint tokenId) external override {
        safeTransferFrom(from, to, tokenId, "");
    }

    // 铸造
    function _mint(address to, uint tokenId) internal virtual {
        require(to != address(0), "mint to zero address");
        require(_owners[tokenId] == address(0), "token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    // 销毁
    function _burn(uint tokenId) internal virtual {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner, "not owner of token");

        _approve(owner, address(0), tokenId);
        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    // 计算tokenURI的baseURI，需要自行实现
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    // [查询]实现IERC721Metadata的tokenURI函数，查询metadata
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_owners[tokenId] != address(0), "Token Not Exist");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }
}