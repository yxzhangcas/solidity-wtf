// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Mapping {
    // mapping(_KeyType => _ValueType)
    mapping(uint => address) public idToAddress;
    mapping(address => address) public swapPair;

    // 规则1：_KeyType只能使用默认类型，如uint、address等；_ValueType可以使用自定义类型
    struct Student {
        uint256 id;
        uint256 score;
    }
    //mapping(Student => uint) public illegalMapping;
    mapping(uint => Student) public legalMapping;

    // 规则2：mapping必须是storage，可以是状态和变量，但不能作为参数或返回值
    // 规则3：如果mapping设置为public，默认提供getter方法
    // 规则4：通过_Mapping[_Key] = _Value添加键值对
    function writeMap(uint _Key, address _Value) public {
        idToAddress[_Key] = _Value;
    }

    // 原理1：不存储key的实际内容，没有length信息
    // 原理2：通过keccak256(key)作为offset取value
    // 原理3：未使用空间都为0，所以未赋值的键值都是0
}