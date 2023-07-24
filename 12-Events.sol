// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Events {
    // EVM日志抽象，支持RPC监听，消耗2000gas，是存储变量的10%
    // 规则：event <EventName> (<TYPE> [indexed] <NAME> [, <TYPE> [indexed] <NAME>, ...]);

    // indexed: 索引，对应单独topic，最多3个，大小固定256bit
    event Transfer(address indexed from, address indexed to, uint256 value);

    mapping(address => uint256) public _balances;

    function _transfer(address from, address to, uint256 amount) external {
        _balances[from] = 100000000;
        _balances[from] -= amount;
        _balances[to] += amount;

        // 记录事件
        emit Transfer(from, to, amount);

        // 可以通过MetaMask的测试网SepoliaETH进行部署和调用，并通过区块链浏览器查看Log数据：https://sepolia.etherscan.io/tx/0xa696b35fa3e9aaca57ea7492aa2cc4345d5dcfa06705d2dc2dab25adf29486f5#eventlog
    }
}