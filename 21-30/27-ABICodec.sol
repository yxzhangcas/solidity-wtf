// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ABICodec {
    // API: Application Binary Interface
    // Encode: abi.encode, abi.encodePacked, abi.encodeWithSignature, abi.encodeWithSelector
    // Decode: abi.decode

    uint x = 10;
    address addr = 0x7A58c0Be72BE218B41C608b7Fe7C5bB630736C71;
    string name = "0xAA";
    uint[2] array = [5, 6];

    function encode() public view returns (bytes memory result) {
        result = abi.encode(x, addr, name, array);  //将每个参数填充为32个字节，即256bit
    }

    // 0x000000000000000000000000000000000000000000000000000000000000000a   // uint: 10
    //   0000000000000000000000007a58c0be72be218b41c608b7fe7c5bb630736c71   // addr
    //   00000000000000000000000000000000000000000000000000000000000000a0   // addr size? 160
    //   0000000000000000000000000000000000000000000000000000000000000005   // array[0]
    //   0000000000000000000000000000000000000000000000000000000000000006   // array[1]
    //   0000000000000000000000000000000000000000000000000000000000000004   // string length? 4
    //   3078414100000000000000000000000000000000000000000000000000000000   // string: "0xAA"

    function encodePacked() public view returns (bytes memory result) {
        result = abi.encodePacked(x, addr, name, array);
    }

    // 0x000000000000000000000000000000000000000000000000000000000000000a   // uint: 10
    //   7a58c0be72be218b41c608b7fe7c5bb630736c71                           // addr
    //   30784141                                                           // string: "0xAA"
    //   0000000000000000000000000000000000000000000000000000000000000005   // array[0]
    //   0000000000000000000000000000000000000000000000000000000000000006   // array[1]

    function encodeWithSignature() public view  returns (bytes memory result) {
        return abi.encodeWithSignature("foo(uint256,address,string,uint256[2])", x, addr, name, array);  //第一个参数是函数签名：<fun>(<arg type>,...)
    }

    // 0xe87082f1                                                           // 4字节函数选择器
    //   000000000000000000000000000000000000000000000000000000000000000a
    //   0000000000000000000000007a58c0be72be218b41c608b7fe7c5bb630736c71
    //   00000000000000000000000000000000000000000000000000000000000000a0
    //   0000000000000000000000000000000000000000000000000000000000000005
    //   0000000000000000000000000000000000000000000000000000000000000006
    //   0000000000000000000000000000000000000000000000000000000000000004
    //   3078414100000000000000000000000000000000000000000000000000000000

    function encodeWithSelector() public view  returns (bytes memory result) {
        return abi.encodeWithSelector(bytes4(keccak256("foo(uint256,address,string,uint256[2])")), x, addr, name, array);  //第一个参数是函数选择器：bytes4(keccak256(<fun>(<arg type>,...)))
    }

    // 0xe87082f1                                                           // 4字节函数选择器
    //   000000000000000000000000000000000000000000000000000000000000000a
    //   0000000000000000000000007a58c0be72be218b41c608b7fe7c5bb630736c71
    //   00000000000000000000000000000000000000000000000000000000000000a0
    //   0000000000000000000000000000000000000000000000000000000000000005
    //   0000000000000000000000000000000000000000000000000000000000000006
    //   0000000000000000000000000000000000000000000000000000000000000004
    //   3078414100000000000000000000000000000000000000000000000000000000

    // decode 只能解码 encode 的输出，另外三个无法解码，但可以人工修改为 encode 的结构再解码
    function decode(bytes memory data) public pure returns (uint dx, address daddr, string memory dname, uint[2] memory darray) {
        // bytes类型的数据如何定义？
        //data = bytes("0x000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000007a58c0be72be218b41c608b7fe7c5bb630736c7100000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000043078414100000000000000000000000000000000000000000000000000000000");
        // 需要明确指定decode后的数据类型
        (dx, daddr, dname, darray) = abi.decode(data, (uint, address, string, uint[2]));
    }


    // 用法1：配合call实现对合约的底层调用
    // function use1() public pure returns (uint256) {
    //     bytes4 selector = contract.getValue.selector;
    //     bytes memory data = abi.encodeWithSignature(selector, _x);
    //     (bool success, bytes memory returnedData) = address(contract).staticcall(data);
    //     require(success);
    //     return abi.decode(returnedData, (uint256));
    // }

    // 用法2：ether.js中实现合约的导入和函数调用
    // function use2() public pure {
    //     const wavePortalContract = new ethers.Contract(contractAddress, contractABI, signer);
    //     const waves = await wavePortalContract.getAllWaves();
    // }

    // 用法3：对不开源合约反编译后，通过ABI进行调用
    // function use3() public pure returns (uint256) {
    //     bytes memory data = abi.encodeWithSelector(bytes4(0x533ba33a));

    //     (bool success, bytes memory returnedData) = address(contract).staticcall(data);
    //     require(success);

    //     return abi.decode(returnedData, (uint256));
    // }
}