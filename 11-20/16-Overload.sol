// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Overload {
    // 可以重载函数，不能重载modifier
    // 重载的函数编译完具有不同的选择器selector值
    function saySomething() public pure returns (string memory) {
        return "Nothing";
    }
    function saySomething(string memory sth) public pure returns (string memory) {
        return sth;
    }

    // 如果出现多个函数都匹配的情况，则报错
    function f(uint8 _in) public pure returns (uint8 out) {
        out = _in;
    }
    function f(uint256 _in) public pure returns (uint256 out) {
        out = _in;
    }

    function f() public pure returns (uint out) {
        //f(50);            //编译不通过，同时匹配了两个函数
        //f(uint8(50));     //编译不通过，同时匹配了两个函数
        f(uint256(50));     //编译通过，只能匹配一个函数
        return 0;
    }
}