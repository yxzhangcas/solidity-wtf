// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// 函数选择器是函数签名哈希的前4个字节，范围很小，两个不同的函数可能会有相同的选择器
contract Foo {
    // 下面这两个函数的选择器就是冲突的，编译器会直接警报
    // function burn(uint256) external {}
    // function collate_propagate_storage(bytes16) external {}
    bytes4 public selector1 = bytes4(keccak256("burn(uint256)"));                           // 0x42966c68
    bytes4 public selector2 = bytes4(keccak256("collate_propagate_storage(bytes16)"));      // 0x42966c68
}

// 代理合约
contract TransparentProxy {
    address implementation;
    address admin;
    string public words;

    constructor(address _implementation) {
        admin = msg.sender;
        implementation = _implementation;
    }

    fallback() external payable {
        require(msg.sender != admin);   // 调用者不能是管理员，必须是其它地址
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
    }
    receive() external payable {}

    function upgrade(address newImplementation) external {
        if (msg.sender != admin) {
            revert();
        }
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
// 2. 部署TransparentProxy，并指向Logic1
// 3. 底层调用函数选择器0xc2985578，执行失败
// 4. 切换钱包地址，底层调用函数选择器0xc2985578，执行成功，words改为foo
// 5. 切换管理员地址，调用upgrade指向Logic2
// 6. 切换钱包地址，底层调用函数选择器0xc2985578，执行成功，words改为new

// 将代理升级的权限和逻辑调用的权限隔离到不同的钱包地址，避免出现两者同时被修改。
// 风险：
//  1. 如果逻辑合约的a函数和代理合约的升级函数的选择器相同，那么管理人就会在调用a函数的时候，将代理合约升级成一个黑洞合约，后果不堪设想。
//  2. 即：本来是要执行逻辑合约的实际实现，但由于函数选择器冲突，实际执行了upgrade，导致代理指向了不存在的逻辑合约。
// 这种实现方式比较浪费gas
