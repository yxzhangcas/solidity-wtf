// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// abstract合约
abstract contract InsertionSort {
    function insertionSort(uint[] memory a) public pure virtual returns (uint[] memory);    //未实现函数体
}

// 接口规则：1-不包含状态变量；2-不包含构造函数；3-只能继承接口；4-函数都是external且都无函数体；5-继承的合约实现全部接口功能

abstract contract Base {
    string public name = "Base";
    function getAlias() public pure virtual returns(string memory);
}

contract BaseImpl is Base {
    function getAlias() public pure override returns(string memory) {
        return "BaseImpl";
    }
}

interface I {
    function getName() external pure returns (string memory);
}

contract Imp is I {
    function getName() external pure override returns (string memory) {
        return "IMP";
    }
}