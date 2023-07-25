// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// delegatecall也是address的成员函数，调用其它合约函数时，会保留当前合约的上下文，而不是使用其它合约的上下文
// 用法：_address.delegatecall{gas: GAS}(abi.encodeWithSignature("func(type,...)", args...))
// delegatecall不能发送ETH，只能指定gas
// 场景：代理合约-存储和逻辑分离，代理存储，逻辑执行，便于升级逻辑；EIP-2535 钻石标准

contract C {
    uint public num;
    address public sender;

    event LogC(uint amount, uint gas);

    function setVars(uint _num) public payable {
        num = _num;
        sender = msg.sender;

        emit LogC(msg.value, gasleft());
    }
}

contract B {
    // delegatecall 调用的合约变量存储布局必须相同（包括类型、长度、顺序），名称可以不同
    uint public num1;
    address public sender1;

    event Log(bool, bytes);

    function callSetVars(address _addr, uint _num) external payable {
        // 定义为uint的参数，在函数签名中使用uint256
        (bool success, bytes memory data) = _addr.call{value: 100000000, gas: 100000000}(abi.encodeWithSignature("setVars(uint256)", _num));
        emit Log(success, data);
    }

    function delegatecallSetVars(address _addr, uint _num) external payable {
        (bool success, bytes memory data) = _addr.delegatecall{gas: 100000000}(abi.encodeWithSignature("setVars(uint256)", _num));
        emit Log(success, data);
    }
}