// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "31-40/34-ERC721.sol";

// 生成MerkleTree的网页：https://lab.miguelmota.com/merkletreejs/example/
// 生成MerkleTree的JS库：https://github.com/merkletreejs/merkletreejs

library MerkleProof {
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }
}

contract MerkleTree is ERC721Impl {

    bytes32 public immutable root;                      // Merkle Root
    mapping(address => bool) public mintedAddress;      // 已经mint的地址

    // 0xeeefd63003e0e702cb41cd0043015a6e26ddb38073cc6ffeb0ba3e808ba8c097
    constructor(string memory name, string memory symbol, bytes32 merkleroot) ERC721Impl(name, symbol) {
        root = merkleroot;
    }

    // account = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // tokenId = 0
    // proof = ["0x999bf57501565dbd2fdcea36efa2b9aef8340a8901e3459f4a4c926275d36cdb","0x4726e4102af77216b09ccd94f40daa10531c87c4d60bba7f3b3faf5ff9f19b3c"]
    function mint(address account, uint256 tokenId, bytes32[] calldata proof) external {
        require(_verify(_leaf(account), proof), "invalid merkle proof");
        require(!mintedAddress[account], "already minted!");
        _mint(account, tokenId);
        mintedAddress[account] = true;
    }

    function _leaf(address account) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(account));
    }

    function _verify(bytes32 leaf, bytes32[] memory proof) internal view returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }
}

