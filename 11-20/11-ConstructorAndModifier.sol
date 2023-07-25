// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ConstructorAndModifier {
    address public owner;

    constructor() {
        owner = msg.sender;     // 合约创建账号地址
    }

    // 合约内部定义modifier，使用合约的状态数据
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // 使用modifier
    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // 标准实现：https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
}

