// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Constant {
    // constant 只有数值变量可以声明，且声明时必须初始化
    uint256 public constant CONSTANT_NUM = 10;
    string public constant CONSTANT_STRING = "0xAA";
    bytes public constant CONSTANT_BYTES = "WTF";
    address public constant CONSTANT_ADDRESS = 0x1234567890123456789012345678901234567890;

    // immutable 只有数值变量可以声明，string和bytes不能声明，可以声明或构造函数中初始化
    uint256 public immutable IMMUTABLE_NUM = 999;
    address public immutable IMMUTABLE_ADDRESS;
    uint256 public immutable IMMUTABLE_BLOCK;
    uint256 public immutable IMMUTABLE_TEST;

    constructor() {
        IMMUTABLE_ADDRESS = address(this);
        IMMUTABLE_BLOCK = block.number;
        IMMUTABLE_TEST = test();

        //CONSTANT_NUM = 100;       //不能在构造函数初始化
        //IMMUTABLE_NUM = 100;      //只能初始化一次
        //IMMUTABLE_TEST = 100;     //只能初始化一次
    }

    function test() public pure returns (uint256) {
        uint256 what = 666;
        return what;
    }
}