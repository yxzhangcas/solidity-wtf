// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// 导入库合约
import "17-StringsLib.sol";

// 库合约特点：1-不能存在状态变量；2-不能继承被继承；3-不能接收以太币；4-不能被销毁

contract UseLibrary {
    // 利用using for指令，附加库函数到任何类型，添加为成员，变量作为第一个参数传入
    using Strings for uint256;
    function getString1(uint256 _number) public pure returns (string memory) {
        return _number.toHexString();
    }

    // 直接通过库合约名进行调用
    function getString2(uint256 _number) public pure returns (string memory) {
        return Strings.toHexString(_number);
    }
}

// 常用库合约：
// String: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/4a9cc8b4918ef3736229a5cc5a310bdc17bf759f/contracts/utils/Strings.sol
// Address: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/4a9cc8b4918ef3736229a5cc5a310bdc17bf759f/contracts/utils/Address.sol
// Create2: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/4a9cc8b4918ef3736229a5cc5a310bdc17bf759f/contracts/utils/Create2.sol
// Arrays: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/4a9cc8b4918ef3736229a5cc5a310bdc17bf759f/contracts/utils/Arrays.sol

// 构建会出现两个合约，当前合约和库合约，部署当前合约到链上，会先部署库合约上链，存在两个合约的部署。
// 对同一个构建完成的字节码，lib部署一次后，多次部署调用contract不会再次部署lib，即：链上存在找到lib便可以直接使用。
// 重新构建的字节码会有变化，所以需要重新部署，才能被找到。【如果直接使用已部署lib的地址进行类型转换，应该就不用重新部署了吧，猜测。】