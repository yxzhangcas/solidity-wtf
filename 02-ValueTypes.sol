// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ValueTypes {
    // 布尔值
    bool public _bool = true;

    // 布尔运算
    bool public _bool1 = !_bool;
    bool public _bool2 = _bool && _bool1;   // 短路计算
    bool public _bool3 = _bool || _bool1;   // 短路计算
    bool public _bool4 = _bool == _bool1;
    bool public _bool5 = _bool != _bool1;

    // 整型
    int public _int = -1;
    uint public _uint = 1;
    uint256 public _number = 20230723;

    // 整数运算
    uint256 public _number1 = _number + 1;
    uint256 public _number2 = 2**2;
    uint256 public _number3 = 7 % 2;
    bool public _numberbool = _number2 > _number3;

    // 地址
    address public _address = 0x7A58c0Be72BE218B41C608b7Fe7C5bB630736C71;
    address payable public _address1 = payable(_address);

    // 地址类型的成员
    uint256 public balance = address(this).balance;

    // 固定长度字节数组
    bytes32 public _bytes32 = "MiniSolidity";
    bytes1 public _bytes1 = _bytes32[0];

    // 枚举(uint)
    enum ActionSet { Buy, Hold, Sell }

    // 枚举变量
    ActionSet action = ActionSet.Sell;

    // 枚举转换
    function enumToUint() external view returns (uint) {
        return uint(action);
    }

    /**
     * 测验内容
     */
    constructor() payable  {}

    function testTransfer() public {
        _address1.transfer(1);
        balance = address(this).balance;
    }


    bool public _a = 1 + 1 != 2 || 0 / 1 == 1;
    bool public _b = 1 + 1 != 2 || 1 - 1 > 0;
    bool public _c = 1 + 1 == 2 && 1 ** 2 == 2;
    bool public _d = 1 - 1 == 0 && 1 % 2 == 1;
}