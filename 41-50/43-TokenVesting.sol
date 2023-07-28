// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract TokenVesting {

    event ERC20Released(address indexed token, uint256 amount);

    mapping(address => uint256) public erc20Released;       // 代币地址 - 已释放代币
    address public immutable beneficiary;                   // 受益人地址
    uint256 public immutable start;                         // 起始时间戳
    uint256 public immutable duration;                      // 归属期

    constructor(address beneficiaryAddress, uint256 durationSeconds) {
        require(beneficiaryAddress != address(0), "VestingWallet: beneficiary is zero address");
        beneficiary = beneficiaryAddress;
        start = block.timestamp;
        duration = durationSeconds;
    }

    // 提币
    function release(address token) public {
        uint256 releasable = vestedAmount(token, uint256(block.timestamp)) - erc20Released[token];
        erc20Released[token] += releasable;
        emit ERC20Released(token, releasable);
        IERC20(token).transfer(beneficiary, releasable);
    }
    // 计算可提笔数量
    function vestedAmount(address token, uint256 timestamp) public view returns (uint256) {
        uint256 totalAllocation = IERC20(token).balanceOf(address(this)) + erc20Released[token];
        if (timestamp < start) {
            return 0;
        } else if (timestamp > start + duration) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start)) / duration;
        }
    }
}

// 1. 部署ERC20合约
// 2. 为自己铸造代币mint
// 3. 部署此合约，受益人自己
// 4. 将ERC合约的代币转给此合约
// 5. 提取ERC20合约中的币