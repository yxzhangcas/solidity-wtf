// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ArrayAndStructTypes {
    // 固定长度
    uint[8] array1;
    bytes1[5] array2;
    address[100] array3;

    // 可变长度(动态数组)
    uint[] array4;
    bytes1[] array5;
    address[] array6;
    bytes array7;  //bytes也是动态数组，但是没有[]下标
    
    function fun1() public pure {
        // memory动态数组，声明长度后不可变
        uint[] memory array8 = new uint[](5);
        bytes memory array9 = new bytes(9);

        // 元素逐个赋值
        array8[0] = 111;
        array8[1] = 222;
        array8[2] = 333;

        // bytes通过字符赋值
        array9[0] = 0x65;
        array9[1] = 'a';
        array9[2] = "A";

        // extra
        array8[0] = 1111;
    }

    // 数组字面量的数字类型默认选择最小空间，也可以显示指定第一个成员的类型

    // 动态数组成员: length, push() - 压0, push(x), pop()
    function arrayPush() public returns (uint[] memory) {
        uint[2] memory a = [uint(1), 2];
        array4 = a;
        array4.push();
        array4.push(333);
        return array4;
    }

    // 结构体
    struct Student {
        uint256 id;
        uint256 score;
    }
    // 初始化
    Student student;

    // 赋值1：创建storage引用进行赋值
    function initStudent1() external {
        Student storage _student = student;
        _student.id = 111;
        _student.score = 149;
    }
    // 赋值2：直接操作状态变量
    function initStudent2() external {
        student.id = 222;
        student.score = 150;
    }

    /**
     * 测验内容
     */
    
    function initStudent3() external {
        student.id = 100;
        student.score = 200;
        Student storage _student = student;
        _student.id = 300;
        _student.score = 400;
    }
}