// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// call 是 address 的成员函数，返回值为 (bool, bytes data)
// call 是官方推荐的出发 fallback/receive 发送ETH的方法
// 不推荐用 call 来调用其它合约，推荐直接调用合约成员函数
// 在不知道其它合约的源码和ABI时，仍可以通过 call 调用对方合约

// 使用规则： address.call{value: ETH, gas: GAS}(abi.encodeWithSignature("func(type1,type2,...)", args...)

contract OtherContract {
    uint256 private _x = 0;

    // event定义时可以带上变量名，也可以只使用变量类型
    event Log(uint amount, uint gas);
    event Fall(uint amount, uint gas);

    receive() external payable {}
    fallback() external payable {
        emit Fall(msg.value, gasleft());
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function setX(uint256 x) external payable {
        _x = x;
        if (msg.value > 0) {
            emit Log(msg.value, gasleft());
        }
    }

    function getX() external view returns (uint x) {
        x = _x;
    }
}

contract Call {
    event Response(bool success, bytes data);

    function callSetX(address payable _addr, uint256 x) public payable {
        (bool success, bytes memory data) = _addr.call{value: msg.value}(abi.encodeWithSignature("setX(uint256)", x));

        emit Response(success, data);
    }

    function callGetX(address _addr) external returns (uint256) {
        (bool success, bytes memory data) = _addr.call(abi.encodeWithSignature("getX()"));

        emit Response(success, data);
        return abi.decode(data, (uint256));     // call的返回值携带的是被调用函数的返回值，需要decode才能使用
    }

    // 调用不存在的函数，实际执行的是fallback
    function callNonExist(address _addr) external {
        (bool success, bytes memory data) = _addr.call(abi.encodeWithSignature("foo(uint256)"));
        emit Response(success, data);
    }
}

// contract Fund {
//     mapping(address => uint) shares;
//     function withdraw() public {
//         if (payable(msg.sender).call.value(shares[msg.sender])())
//             shares[msg.sender] = 0;
//     }
// }