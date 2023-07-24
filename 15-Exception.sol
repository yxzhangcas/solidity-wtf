// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// 三种抛出异常的方法：error(方便高效，搭配revert), require, assert

contract Exception {

    mapping(uint256 => address) public _owners;

    // 自定义error
    error TransferNotOwner();

    function transferOwner1(uint256 tokenId, address newOwner) public {
        // 判断是否符合error逻辑
        if (_owners[tokenId] != msg.sender) {
            revert TransferNotOwner();  //使用revert抛出error
        }
        _owners[tokenId] = newOwner;
    }

    function transferOwner2(uint256 tokenId, address newOwner) public {
        // 判断是否符合require逻辑，并自动抛异常，解释异常原因
        require(_owners[tokenId] == msg.sender, "Transfer Not Owner");
        _owners[tokenId] = newOwner;
    }

    function transferOwner3(uint256 tokenId, address newOwner) public {
        // 判断是否符合assert逻辑，并自动抛异常
        assert(_owners[tokenId] == msg.sender);
        _owners[tokenId] = newOwner;
    }

    /* 测试 */
    // error可以带参数
    error TransferNotOwner1(uint256, address);

    function transferOwner4(uint256 tokenId, address newOwner) public {
        // 判断是否符合error逻辑
        if (_owners[tokenId] != msg.sender) {
            revert TransferNotOwner1(tokenId, newOwner);  //使用revert抛出error
        }
        _owners[tokenId] = newOwner;
    }

    // require可以不解释异常原因，类似assert
    function transferOwner5(uint256 tokenId, address newOwner) public {
        // 判断是否符合require逻辑，并自动抛异常，解释异常原因
        require(_owners[tokenId] == msg.sender);
        _owners[tokenId] = newOwner;
    }
}

// gas消耗：error < assert < require