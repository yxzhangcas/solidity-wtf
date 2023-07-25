// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract OnlyEven {
    constructor(uint a) {
        require(a != 0, "invalid number");          // Error(string memory)
        assert(a != 1);                             // (bytes memory)
    }

    function onlyEven(uint256 b) external pure returns (bool success) {
        require(b % 2 == 0, "Ups! Reverting");
        success = true;
    }
}

contract TryCatch {
    // 只能在external(constructor)中调用
    // try externalContract.f() {...} catch {...}   // this也可以看做外部合约
    // try externalContract.f() returns (Type val) {...} catch {...}    // 带返回值的外部函数
    // try externalContract.f() returns (Type val) {...} catch Error(string memory reason) {...} catch (bytes memory reason) {...}  //捕获特殊的异常原因

    event SuccessEvent();
    event CatchEvent(string message);   // require/revert
    event CatchByte(bytes data);        // assert

    OnlyEven even;

    constructor() {
        even = new OnlyEven(2);
    }

    // 处理合约调用异常
    function execute(uint amount) external returns (bool success) {
        try even.onlyEven(amount) returns (bool _success) {
            emit SuccessEvent();
            return _success;
        } catch Error(string memory reason) {
            emit CatchEvent(reason);
        } catch (bytes memory reason) {     // 无assert，不会触发
            emit CatchByte(reason);
        }
    }
    
    // 处理合约创建异常
    function executeNew(uint a) external returns (bool success) {
        try new OnlyEven(a) returns (OnlyEven _even) {      // 返回值为合约对象
            emit SuccessEvent();
            success = _even.onlyEven(a);
        } catch Error(string memory reason) {
            emit CatchEvent(reason);
        } catch (bytes memory reason) {
            emit CatchByte(reason);
        }
    }
}