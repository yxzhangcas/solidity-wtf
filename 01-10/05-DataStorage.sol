// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract DataStorage {
    
    // 引用类型(array, struct, mapping)在使用时必须声明存储位置(storage, memory, calldata)
    // storage: 链上，状态变量；
    // memory: 内存，参数和临时变量；
    // calldata: 内存，函数入参，不能修改；

    uint[] x = [1, 2, 3];   // 状态变量(storage)

    function fStorage() public {
        // 声明storage变量，创建引用，修改影响x[消耗Gas]
        uint[] storage xStorage = x;
        xStorage[0] = 100;
    }

    function fMemory() public view {
        // 声明memory变量，复制内容，修改不影响x
        uint[] memory xMemory1 = x;
        xMemory1[1] = 111;
        uint[] memory xMemory2 = x;
        xMemory2[2] = 222;
    }

    function fCalldata(uint[] calldata _x) public pure returns (uint[] calldata) {
        // 无法修改
        //_x[0] = 0;
        return _x;
    }

    // 变量作用域：状态变量(state)，局部变量(local)，全局变量(global)
    
    // 状态变量
    uint public _xx = 1;
    uint public _yy;
    string public _zz;

    function foo() external {
        // 更改状态变量的值
        _xx = 111;
        _yy = 222;
        _zz = "333";
    }

    // 局部变量
    function bar() external pure returns (uint) {
        uint xx = 1;
        uint yy = 2;
        uint zz = xx + yy;
        return zz;
    }

    // 全局变量
    function global() external view returns (address, uint, bytes memory) {
        address sender = msg.sender;
        uint blockNum = block.number;
        bytes memory data = msg.data;
        return (sender, blockNum, data);
    }

    /*
     * 常见的全局变量：
     * block.coinbase
     * block.gaslimit
     * block.number
     * block.timestamp
     * msg.data
     * msg.sender
     * msg.sig
     * msg.value
     */
}