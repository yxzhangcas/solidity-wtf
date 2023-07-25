// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// function <function name> (<parameter types>) {public|private|external|internal} [pure|view|payable] [returns (<return types>)]
contract FunctionTypes {
    uint256 public number = 5;

    // default 可以读取和操作状态变量
    function add() external {
        number = number + 1;
    }

    // <pure> 可以return，也可以将return语句省略，通过returns中的变量名进行返回
    function addPure1(uint256 _number) external pure returns (uint256) {
        return _number + 1;
    }
    function addPure2(uint256 _number) external pure returns (uint256 new_number) {
        new_number = _number + 1;
    }

    // <view> 可以return，也可以将return语句省略，通过returns中的变量名进行返回
    function addView1() external view returns (uint256) {
        return number + 1;
    }
    function addView2() external view returns (uint256 new_number) {
        new_number = number + 1;
    }

    // <internal>
    function minus() internal {
        number = number - 1;
    }
    // <external>
    function minusCall() external {
        minus();
    }

    // <payable>
    function minusPayable1() external payable returns (uint256 balance) {
        minus();
        balance = address(this).balance;
    }
    function minusPayable2() external payable returns (uint256) {
        minus();
        return address(this).balance;
    }
}