// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract InitialValue {

    // 值类型
    bool public _bool;          // false
    string public _string;      // ""
    int public _int;            // 0
    uint public _uint;          // 0
    address public _address;    // 0x0000000000000000000000000000000000000000

    enum ActionSet { Buy, Hold, Sell }
    ActionSet public _enum;     // 第一个元素 0

    function fi() internal {}   // internal 空白方程
    function fe() external {}   // external 空白方程


    // 引用类型
    uint[8] public _staticArray;    // 所有成员都为0, [0,0,0,0,0,0,0,0]
    uint[] public _dynamicArray;    // 空数组, []

    mapping(uint => address) public _mapping;   // 所有元素都是默认值

    struct Student {
        uint256 id;
        uint256 score;
    }
    Student public _student;    // 所有成员都是默认值

    // delete
    bool public _bool2 = true;
    string public _string2 = "string";
    int public _int2 = 111;
    address public _address2 = 0x1234567890123456789012345678901234567890;
    ActionSet public _enum2 = ActionSet.Sell;
    uint[2] public _staticArray2 = [2, 3];
    
    function d() external {
        delete _bool2;
        delete _string2;
        delete _int2;
        delete _address2;
        delete _enum2;
        delete _staticArray2;
    }


    /* 测试内容 */

    string public _string3 = "true";

    function d2() external returns (string memory) {
        delete _string3;
        return _string3;
    }
}