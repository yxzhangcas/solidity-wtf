// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Base1 {
    // 同样使用virtual关键字表示可以继承
    // modifier也可以传入参数进行使用
    modifier exactDividedBy2And3(uint _a) virtual {
        require(_a % 2 == 0 && _a % 3 == 0);
        _;
    }
}

// 直接使用父modifier
contract Identifier1 is Base1 {
    function getExactDividedBy2And3(uint _dividend) public exactDividedBy2And3(_dividend) pure returns (uint, uint) {
        return getExactDividedBy2And3WithoutModifier(_dividend);
    }

    function getExactDividedBy2And3WithoutModifier(uint _dividend) public pure returns (uint, uint) {
        uint div2 = _dividend / 2;
        uint div3 = _dividend / 3;
        return (div2, div3);
    }
}

// 重写父modifier
contract Identifier2 is Base1 {

    modifier exactDividedBy2And3(uint _a) virtual override {
        _;
        require(_a % 2 == 0 && _a % 3 == 0);    // 换一下顺序
    }

    function getExactDividedBy2And3(uint _dividend) public exactDividedBy2And3(_dividend) pure returns (uint, uint) {
        return getExactDividedBy2And3WithoutModifier(_dividend);
    }

    function getExactDividedBy2And3WithoutModifier(uint _dividend) public pure returns (uint, uint) {
        uint div2 = _dividend / 2;
        uint div3 = _dividend / 3;
        return (div2, div3);
    }
}