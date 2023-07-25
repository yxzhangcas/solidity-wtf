// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Return {
    // 返回多个变量
    function returnMultiple() public pure returns (uint256, bool, uint256[3] memory) {
        return (1, true, [uint256(1), 2, 5]);
    }
    // 命名式返回
    function returnNamed1() public pure returns (uint256 _number, bool _bool, uint256[3] memory _array) {
        _number = 2;
        _bool = false;
        _array = [uint(3), 2, 1];
    }
    // 命名式返回，依然支持return
    function returnNamed2() public pure returns (uint256 _number, bool _bool, uint256[3] memory _array) {
        return (1, true, [uint256(1), 2, 5]);
    }

    // 读取所有返回值
    function returnAll1() public pure returns (uint256 _number, bool _bool, uint256[3] memory _array) {
        (_number, _bool, _array) = returnNamed1();
    }
    function returnAll2() public pure returns (uint256, bool, uint256[3] memory) {
        (uint256 _number, bool _bool, uint256[3] memory _array) = returnNamed1();
        return (_number, _bool, _array);
    }

    // 读取部分返回值
    function returnPart1() public pure returns (uint256[3] memory _array) {
        (, , _array) = returnNamed1();
    }
    function returnPart2() public pure returns (uint256[3] memory) {
        (, , uint256[3] memory _array) = returnNamed1();
        return _array;
    }

    /**
     * 测验内容
     */
    
    function returnNamed() public pure returns (uint256 _number) {
        // bool _bool = true;
        // string memory _str = '0xAA';
        _number = 2;
    }
}