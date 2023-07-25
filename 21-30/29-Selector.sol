// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// 调用智能合约本质是发送一段 calldata, 其中前4个字节就是 selector
contract Selector {
    event Log(bytes data);

    // addr: 0xe2899bddFD890e320e643044c6b95B9B0b84157A
    // a: 456
    // data: 0x40c10f19     // selector
    //      000000000000000000000000e2899bddfd890e320e643044c6b95b9b0b84157a    // addr
    //      00000000000000000000000000000000000000000000000000000000000001c8    // a
    function mint(address addr, uint a) external {
        emit Log(msg.data);
    }

    function mintSelector() external pure returns (bytes4 mSelector) {
        mSelector = bytes4(keccak256("mint(address,uint256)"));
    }

    function callWithSignature() external returns (bool, bytes memory) {
        (bool success, bytes memory data) = address(this).call(abi.encodeWithSelector(0x40c10f19, "0xe2899bddFD890e320e643044c6b95B9B0b84157A", 456));
        return (success, data);
    }
}