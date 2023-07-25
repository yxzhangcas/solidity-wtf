// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// 关键字：selfdestruct，用法：selfdestruct(_addr);

contract DeleteContract {
    uint public value = 10;     //合约销毁后，变量值清空，查到的是默认值

    constructor() payable {}

    receive() external payable {}

    // 此接口的调用最好可以限制使用人员，只能创建者调用：紧急情况下的后门功能
    function deleteContract() external {
        selfdestruct(payable(msg.sender));      //WARN: selfdestruct已经废弃了，不推荐使用，没查到替代用法
        // https://eips.ethereum.org/EIPS/eip-4758
    }

    function getBalance() external view returns (uint balance) {    //合约销毁后，返回默认值
        balance = address(this).balance;
    }
}