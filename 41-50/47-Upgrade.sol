// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleUpgrade {
    address public implementation;
    address public admin;
    string public words;

    constructor(address _implementation) {
        implementation = _implementation;
        admin = msg.sender;
    }

    fallback() external payable {
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
    }

    receive() external payable {}

    function upgrade(address newImplementation) external {
        require(msg.sender == admin);
        implementation = newImplementation;
    }
}

contract Logic1 {
    address public implementation;
    address public admin;
    string public words;

    function foo() public {
        words = "foo";
    }
}

contract Logic2 {
    address public implementation;
    address public admin;
    string public words;

    function foo() public {
        words = "new";
    }
}

// 1. 部署Logic1和Logic2
// 2. 部署SimpleUpgrade，指向Logic1
// 3. 通过calldata执行0xc2985578，words变为foo
// 4. 通过upgrade指向Logic2
// 5. 通过calldata执行0xc2985578，words变为new

// 此合约存在选择器冲突的问题
