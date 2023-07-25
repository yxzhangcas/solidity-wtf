// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract Faucet {

    uint256 public amountAllowed = 100;     //每次领取100单位代币
    address public tokenContract;           //token合约地址
    mapping(address => bool) public requestedAddress;   //领取过代币的地址

    event SendToken(address indexed Receiver, uint256 indexed Amount);  //代币发送事件

    //传入代币合约
    constructor(address _tokenContract) {
        tokenContract = _tokenContract;
    }

    //用户领取代币
    function requestTokens() external {
        require(requestedAddress[msg.sender] == false, "Can't Request Multiple Times!");
        IERC20 token = IERC20(tokenContract);
        require(token.balanceOf(address(this)) >= amountAllowed, "Faucet Empty");

        token.transfer(msg.sender, amountAllowed);
        requestedAddress[msg.sender] = true;

        emit SendToken(msg.sender, amountAllowed);
    }
}