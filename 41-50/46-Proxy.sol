// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// 合约数据和合约逻辑分离，可以通过部署新逻辑修改指向地址，完成最小成本最少gas的合约升级

// 代理合约
contract Proxy {
    address public implementation;      // 逻辑合约地址

    constructor(address implementation_) {
        implementation = implementation_;
    }
    receive() external payable {}
    fallback() external payable {
        address _implementation = implementation;

        // 内联魔法：没有返回值的callback函数也可以返回数据。
        assembly {      // 内联代码不需要分号结尾
            calldatacopy(0, 0, calldatasize())         // msg.data拷贝到内存：内存起始位置、calldata起始位置、calldata长度
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)     // 调用合约
            returndatacopy(0, 0, returndatasize())     // return data 拷贝到内存

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }

        }
    }
}

// 逻辑合约
contract Logic {
    address public implementation;      // slot和代理合约保持一致
    uint public x = 99;

    event CallSuccess();

    function increment() external returns(uint) {
        emit CallSuccess();
        return x + 1;
    }
}

// 调用者合约
contract Caller {
    address public proxy;

    constructor(address proxy_) {
        proxy = proxy_;
    }

    function increment() external returns (uint) {
        (, bytes memory data) = proxy.call(abi.encodeWithSignature("increment()"));
        return abi.decode(data, (uint));
    }
}

// 1. 部署Logic合约，调用函数验证返回结果100
// 2. 部署Proxy合约，初始化参数填Logic合约地址
// 3. 通过Lowlevel方式调用increment函数，函数选择器0xd09de08a，无返回值，但触发了Logic合约的成功event。【fallback函数本身无返回值】
// 4. 部署Caller合约，初始化参数填Proxy合约地址，调用incre函数，返回1（用了Proxy的Slot）
