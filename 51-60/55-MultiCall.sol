// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// MultiCall(多重调用)合约的设计能在一次交易中执行多个函数调用。
// 方便性、节省gas、原子性

// https://github.com/mds1/multicall/blob/main/src/Multicall3.sol

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract MCERC20 is ERC20 {
    constructor() ERC20("WTF", "WTF") {}

    function mint(address account, uint256 value) public {
        _mint(account, value);
    }
}

contract MultiCall {
    struct Call {
        address target;             // 目标合约
        bool allowFailure;
        bytes callData;
    }
    struct Result {
        bool success;
        bytes returnData;
    }

    function multiCall(Call[] calldata calls) public returns (Result[] memory returnData) {
        uint256 length = calls.length;
        returnData = new Result[](length);
        Call calldata calli;

        for (uint256 i = 0; i < length; i++) {
            Result memory result = returnData[i];
            calli = calls[i];
            (result.success, result.returnData) = calli.target.call(calli.callData);    // 循环调用
            if (!(calli.allowFailure || result.success)) {
                revert("Multicall: call failed");
            }
        }
    }
}

// 1. 部署MCERC20合约
// 2. 部署MultiCall合约
// 3. 生成mint函数的calldata：
//      1. 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 10000 => 0x40c10f190000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc40000000000000000000000000000000000000000000000000000000000002710
//      2. 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 88888 => 0x40c10f19000000000000000000000000ab8483f64d9c6d1ecf9b849ae677dd3315835cb20000000000000000000000000000000000000000000000000000000000015b38
// 4. 组成multiCall函数的参数：
//      [["0x14A919590E83B987aF5f7A3273Db70076A794CD0",true,"0x40c10f190000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc40000000000000000000000000000000000000000000000000000000000002710"],["0x14A919590E83B987aF5f7A3273Db70076A794CD0",true,"0x40c10f19000000000000000000000000ab8483f64d9c6d1ecf9b849ae677dd3315835cb20000000000000000000000000000000000000000000000000000000000015b38"]]