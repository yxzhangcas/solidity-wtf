// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// abstract合约不可部署，只能被继承
abstract contract A {
    uint public a;

    constructor(uint _a) {
        a = _a;
    }
}

// 继承1
contract B is A(111) {}

// 继承2
contract C is A {
    constructor(uint _c) A(_c * _c) {}
}