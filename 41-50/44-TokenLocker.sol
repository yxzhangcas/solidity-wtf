// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract TokenLocker {

    event TokenLockStart(address indexed beneficiary, address indexed token, uint256 startTime, uint256 lockTime);
    event Release(address indexed beneficiary, address indexed token, uint256 releaseTime, uint256 amount);

    IERC20 public immutable token;
    address public immutable beneficiary;
    uint256 public immutable lockTime;
    uint256 public immutable startTime;

    // 此合约用于单个受益人和单个代币
    constructor(IERC20 token_, address beneficiary_, uint256 lockTime_) {
        require(lockTime_ > 0, "TokenLock: lock time should greater than 0");
        token = token_;
        beneficiary = beneficiary_;
        lockTime = lockTime_;
        startTime = block.timestamp;

        emit TokenLockStart(beneficiary_, address(token_), block.timestamp, lockTime_);
    }
    // 锁仓时间结束，代币提给受益人
    function release() public {
        require(block.timestamp >= startTime + lockTime, "TokenLock: current time is before release time");
        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "TokenLock: no tokens to release");
        token.transfer(beneficiary, amount);

        emit Release(msg.sender, address(token), block.timestamp, amount);
    }
}

// 1. 部署ERC20合约
// 2. 为自己铸造代币mint
// 3. 部署此合约，受益人自己
// 4. 将ERC合约的代币转给此合约
// 5. 锁仓结束后提取ERC20合约中的币