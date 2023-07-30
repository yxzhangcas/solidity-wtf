// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract ERC20Impl is ERC20 {
    constructor() ERC20("WTF", "WTF") {}

    function mint(address account, uint256 value) public {
        _mint(account, value);
    }
    function burn(address account, uint256 value) public {
        _burn(account, value);
    }
}