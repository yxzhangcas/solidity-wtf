// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// import "18-Yeye.sol";   // 通过相对位置
import '18-Yeye.sol';   // 通过相对位置

// 通过网址引用
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

// 通过npm的目录导入
import '@openzeppelin/contracts/access/Ownable.sol';

// 通过全局符号导入特定合约
// import {Yeye} from "13-Inheritance.sol";

// 设置别名
import {Yeye as Grandpa} from "13-Inheritance.sol";

// 导入全部合约，设置上层别名
import * as Wowo from "13-Inheritance.sol";

contract Import {
    // 导入Address库成功
    using Address for address;
    // 导入合约成功
    Yeye yeye = new Yeye();
    Grandpa grandpa = new Grandpa();
    Wowo.Baba baba = new Wowo.Baba();   // 分层方式指定合约

    // 测试
    function test() external {
        yeye.hip();
        grandpa.pop();
        baba.hip();
    }
}