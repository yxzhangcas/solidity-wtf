// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;        // 版本号对齐

// 引用协议
import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";

// abstract合约
abstract contract InsertionSort {
    function insertionSort(uint[] memory a) public pure virtual returns (uint[] memory);    //未实现函数体
}

// 接口规则：1-不包含状态变量；2-不包含构造函数；3-只能继承接口；4-函数都是external且都无函数体；5-继承的合约实现全部接口功能

// ERC721代币接口
contract interactBAYC {
    // 利用BAYC地址创建接口合约变量（ETH主网）
    IERC721 BAYC = IERC721(0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D);

    // 通过接口调用BAYC的balanceOf()查询持仓量
    function balanceOfBAYC(address owner) external view returns (uint256 balance){
        return BAYC.balanceOf(owner);
    }

    // 通过接口调用BAYC的safeTransferFrom()安全转账
    function safeTransferFromBAYC(address from, address to, uint256 tokenId) external{
        BAYC.safeTransferFrom(from, to, tokenId);
    }
}