// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// UUPS: universal upgradeable proxy standard, 通用可升级代理标准
// 核心：将升级函数放到逻辑合约中，而不是代理合约，如果出现选择器冲突，在同一个合约中冲突，编译阶段就会发现
// 由于是delegatecall，因此逻辑合约修改的也是代理合约的状态

contract UUPSProxy {
    address public implementation;
    address public admin;
    string public words;

    constructor(address _implementation) {
        admin = msg.sender;
        implementation = _implementation;
    }

    fallback() external payable {
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
    }
    receive() external payable {}
}

contract UUPS1 {
    address public implementation;
    address public admin;
    string public words;

    // 函数选择器：0xc2985578
    function foo() public {
        words = "old";
    }

    // 函数选择器：0x0900f010
    function upgrade(address newImplementation) external {
        require(msg.sender == admin);
        implementation = newImplementation;
    }
}

contract UUPS2 {
    address public implementation;
    address public admin;
    string public words;

    // 函数选择器：0xc2985578
    function foo() public {
        words = "new";
    }

    // 函数选择器：0x0900f010
    function upgrade(address newImplementation) external {
        require(msg.sender == admin);
        implementation = newImplementation;
    }
}

// 1. 部署UUPS1和UUPS2
// 2. 部署UUPSProxy，指向UUPS1
// 3. 底层调用函数选择器0xc2985578, words变为old
// 4. 利用https://abi.hashex.org/，填写function(upgrade)和arguemnt(address:UUPS2地址), 返回: 0900f010000000000000000000000000ac40c9c8dade7b9cf37aebb49ab49485ebd3510d
// 5. 底层调用0900f010000000000000000000000000ac40c9c8dade7b9cf37aebb49ab49485ebd3510d，指向UUPS2
// 6. 底层调用函数选择器0xc2985578, words变为new