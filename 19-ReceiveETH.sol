// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// 特殊回调函数：receive(), fallback()

contract ReceiveETH {
    // receive 只处理接收ETH，且data为空场景
    event Received(address sender, uint value);
    // 无function，无参数，无返回值
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    // fallback 调用不存在函数时被执行，也可以接收ETH，可用于代理合约
    event Fallbacked(address sender, uint value);
    fallback() external payable {
        emit Fallbacked(msg.sender, msg.value);
    }

    // receive 和 fallback 都不存在，直接发送ETH到合约会报错，可以通过调用带 payable 的函数进行发送
}


// VALUE指定ETH数值，点击Transact按钮，便只发送ETH - Received
// VALUE指定ETH数值，CALLDATA填写随意16进制值，点击Transact，便携带数据发送ETH - Fallbacked
