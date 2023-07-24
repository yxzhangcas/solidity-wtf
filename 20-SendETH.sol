// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract SendETH {
    // 构造函数接收ETH
    constructor() payable {}
    // receive 接收ETH
    receive() external payable {}

    // transfer 发送ETH
    function transferETH(address payable _to, uint256 amount) external payable {
        // gas 限制2300，失败自动回滚交易
        _to.transfer(amount);
    }

    // 错误处理
    error SendFailed();

    // send 发送ETH
    function sendETH(address payable _to, uint256 amount) external payable {
        // gas 限制2300，不会自动回滚，返回bool，需额外处理返回值
        bool success = _to.send(amount);
        if (!success) {
            revert SendFailed();
        }
    }

    // 错误处理
    error CallFailed();

    // call 发送ETH
    function callETH(address payable _to, uint256 amount) external payable {
        // 没有gas限制，不会自动回滚，返回(bool, data)，需额外处理
        // 调用方式：接收方地址.call{value: 发送ETH数额}("")
        (bool success,) = _to.call{value:amount}("");
        if (!success) {
            revert CallFailed();
        }
    }
}