// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IOtherContract {
    function getBalance() external returns (uint);
    function setX(uint256 x) external payable;
    function getX() external view returns (uint x);
}

contract OtherContract {
    uint256 private _x = 0;

    event Log(uint amount, uint gas);

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function setX(uint256 x) external payable { // 可以接收ETH
        _x = x;
        // 检查是否转入ETH
        if (msg.value > 0) {
            emit Log(msg.value, gasleft());
        }
    }

    function getX() external view returns (uint x) {
        x = _x;
    }
}

// 三种使用方式都是对已经部署的合约地址的引用，而不是创建新的合约实例（见18-Import.sol的用法）
contract CallContract {
    function callSetX(address _address, uint256 _x) external {
        OtherContract(_address).setX(_x);
    }
    function callGetX(OtherContract _address) external view returns (uint x) {
        x = _address.getX();
    }
    function callGetX2(address _address) external view returns (uint x) {
        OtherContract oc = OtherContract(_address);
        x = oc.getX();
    }

    // with interface
    function callISetX(address _address, uint256 _x) external {
        IOtherContract(_address).setX(_x);
    }
    function callIGetX(IOtherContract _address) external view returns (uint x) {
        x = _address.getX();
    }
    function callIGetX2(address _address) external view returns (uint x) {
        IOtherContract oc = IOtherContract(_address);
        x = oc.getX();
    }

    // send ETH
    function callSetXWithETH(address _address, uint256 _x, uint256 amount) external payable {
        IOtherContract(_address).setX{value: amount}(_x);
    }
}