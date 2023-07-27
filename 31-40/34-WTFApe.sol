// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "31-40/34-ERC721.sol";

contract WTFApe is ERC721Impl {
    uint public MAX_APES = 10000;

    constructor(string memory name_, string memory symbol_) ERC721Impl(name_, symbol_) {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/";
    }

    function mint(address to, uint tokenId) external {
        require(tokenId >= 0 && tokenId < MAX_APES, "tokenId out of range");
        _mint(to, tokenId);
    }
}