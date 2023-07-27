// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

// ERC20是以太坊代币标准，实现了代币转账基本逻辑：账户余额、转账、授权转账、代币总供给、代币信息（名称、代号、小数位数）
// IERC20是接口合约，定义通用的函数名称、输入参数、输出参数

contract ERC20Impl is IERC20 {  // 2个Event，6个函数（其中3个查询函数可以直接使用public状态实现）

    // 此处的三个override其实是自动添加的getter函数继承了接口函数，本身接口是没有状态的
    mapping(address => uint256) public override balanceOf;      // 地址-Token数量映射
    mapping(address => mapping(address => uint256)) public override allowance;  // 地址-授权-Token数量映射
    uint256 public override totalSupply;    //代币总供给

    string public name;             //名称
    string public symbol;           //代号
    uint8 public decimals = 18;     //小数位数

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    // 转账逻辑
    function transfer(address recipient, uint amount) external override returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // 代币授权逻辑
    function approve(address spender, uint amount) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // 授权转账逻辑
    function transferFrom(address sender, address recipient, uint amount) external override returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // 铸币函数（不在ERC20标准）
    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    // 销币函数（不在ERC20标准）
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    // 自测：普通的四则运算符已经具备了上下溢出的错误检查功能，出现溢出会直接revert！
    function foo(uint a, uint b) public pure returns (uint c) {
        c = a - b;
    }
}