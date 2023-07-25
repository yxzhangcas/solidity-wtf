// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract Airdrop {

    function getSum(uint256[] calldata _arr) public pure returns (uint sum) {
        for (uint i = 0; i < _arr.length; i++) {
            sum = sum + _arr[i];
        }
    }

    // 给此合约授权Token发送，并进行循环发送Token
    function multiTransferToken(address _token, address[] calldata _addresses, uint256[] calldata _amounts) external {
        require(_addresses.length == _amounts.length, "Lengths of Addresses and Amounts NOT EQUAL");
        IERC20 token = IERC20(_token);
        uint _amountSum = getSum(_amounts);
        require(token.allowance(msg.sender, address(this)) >= _amountSum, "Need Approve ERC20 token");
        for (uint8 i; i < _addresses.length; i++) {
            token.transferFrom(msg.sender, _addresses[i], _amounts[i]);
        }
    }

    // 发送ETH空投
    // ["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
    // [9999999999,7777777777]
    // 17777777776
    function multiTransferETH(address payable [] calldata _addresses, uint256[] calldata _amounts) public payable {
        require(_addresses.length == _amounts.length, "Lengths of Addresses and Amounts NOT EQUAL");
        uint _amountSum = getSum(_amounts);
        require(msg.value == _amountSum, "Transfer amount error");  // 空投的金额是当前转入的，不是预存的
        for (uint256 i = 0; i < _addresses.length; i++) {
            _addresses[i].transfer(_amounts[i]);
        }
    }
}

// 空投需要先部署ERC20代币合约，进行mint造币，并通过approve授权空投合约，然后空投合约使用代币合约进行批量口头，两者的地址互引。