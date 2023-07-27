// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "31-40/34-ERC721.sol";

// opensea: 最大的NFT交易市场
// ECDSA 双椭圆曲线数字签名算法：身份认证、不可否认、完整性

// 私钥: 0x227dbb8586117d55284e26620bc76534dfbd2394be34cf4a09cb775d593b6f2b //可以使用MetaMask导入私钥进行账户使用
// 公钥: 0xe16C1623c1AA7D919cd2241d8b36d9E79C1Be2A2
// 消息: 0x1bf2c0ce4546651a1a2feb457b39d891a6b83931cc2454434f39961345ac378c
// 以太坊签名消息: 0xb42ca4636f721c7a331923e764587e98ec577cea1a185f60dfcc14dbb9bd900b
// 签名: 0x390d704d7ab732ce034203599ee93dd5d3cb0d4d1d7c600ac11726659489773d559b12d220f99f41d17651b0c1c6a669d346a397f8541760d6b32a5725378b241c

library ECDSA {

    /*
     * 将mint地址（address类型）和tokenId（uint256类型）拼成消息msgHash
     * _account: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
     * _tokenId: 0
     * 对应的消息msgHash: 0x1bf2c0ce4546651a1a2feb457b39d891a6b83931cc2454434f39961345ac378c
     */
    function getMessageHash(address _account, uint256 _tokenId) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_account, _tokenId));
    }

    // 以太坊签名标准：https://eth.wiki/json-rpc/API#eth_sign，32是hash的字节长度。
    // `EIP191`:https://eips.ethereum.org/EIPS/eip-191`
    // 以太坊签名消息: 0xb42ca4636f721c7a331923e764587e98ec577cea1a185f60dfcc14dbb9bd900b
    function toEthSignedMessageHash(bytes32 hash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    // 利用MetaMask账户的私钥进行签名
    // F12 - Console - >(命令行)
    // 输入：
    // ethereum.enable()
    // account = "0xe16C1623c1AA7D919cd2241d8b36d9E79C1Be2A2"
    // hash = "0x1bf2c0ce4546651a1a2feb457b39d891a6b83931cc2454434f39961345ac378c"
    // ethereum.request({method: "personal_sign", params: [account, hash]})
    // 返回：
    // Promise {<pending>}
    //      [[Prototype]]: Promise
    //      [[PromiseState]]: "fulfilled"
    //      [[PromiseResult]]: "0x390d704d7ab732ce034203599ee93dd5d3cb0d4d1d7c600ac11726659489773d559b12d220f99f41d17651b0c1c6a669d346a397f8541760d6b32a5725378b241c"

    // 利用web3.py进行私钥签名
    // 代码：
    // from web3 import Web3, HTTPProvider
    // from eth_account.messages import encode_defunct
    // private_key = "0x227dbb8586117d55284e26620bc76534dfbd2394be34cf4a09cb775d593b6f2b"
    // address = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"
    // rpc = 'https://rpc.ankr.com/eth'
    // w3 = Web3(HTTPProvider(rpc))
    // #打包信息
    // msg = Web3.solidityKeccak(['address','uint256'], [address,0])
    // print(f"消息：{msg.hex()}")
    // #构造可签名信息
    // message = encode_defunct(hexstr=msg.hex())
    // #签名
    // signed_message = w3.eth.account.sign_message(message, private_key=private_key)
    // print(f"签名：{signed_message['signature'].hex()}")
    // 输出：
    // 消息：0x1bf2c0ce4546651a1a2feb457b39d891a6b83931cc2454434f39961345ac378c
    // 签名：0x390d704d7ab732ce034203599ee93dd5d3cb0d4d1d7c600ac11726659489773d559b12d220f99f41d17651b0c1c6a669d346a397f8541760d6b32a5725378b241c

    // 通过签名和消息恢复公钥
    // _msgHash：0xb42ca4636f721c7a331923e764587e98ec577cea1a185f60dfcc14dbb9bd900b
    // _signature：0x390d704d7ab732ce034203599ee93dd5d3cb0d4d1d7c600ac11726659489773d559b12d220f99f41d17651b0c1c6a669d346a397f8541760d6b32a5725378b241c
    // 返回值：0xe16C1623c1AA7D919cd2241d8b36d9E79C1Be2A2
    function recoverSigner(bytes32 _msgHash, bytes memory _signature) internal pure returns (address) {
        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(_signature, 0x20))
            s := mload(add(_signature, 0x40))
            v := byte(0, mload(add(_signature, 0x60)))
        }
        return ecrecover(_msgHash, v, r, s);
    }

    // 对比公钥并验证签名
    // _msgHash：0xb42ca4636f721c7a331923e764587e98ec577cea1a185f60dfcc14dbb9bd900b
    // _signature：0x390d704d7ab732ce034203599ee93dd5d3cb0d4d1d7c600ac11726659489773d559b12d220f99f41d17651b0c1c6a669d346a397f8541760d6b32a5725378b241c
    // _signer：0xe16C1623c1AA7D919cd2241d8b36d9E79C1Be2A2
    function verify(bytes32 _msgHash, bytes memory _signature, address _signer) public pure returns (bool) {
        return recoverSigner(_msgHash, _signature) == _signer;
    }
}

contract SignatureNFT is ERC721Impl {
    address immutable public signer;                // 签名地址
    mapping(address => bool) public mintedAddress;  // 已经mint的地址

    // _signer：0xe16C1623c1AA7D919cd2241d8b36d9E79C1Be2A2
    // 只有持有地址私钥的人才有签名的权限
    constructor(string memory _name, string memory _symbol, address _signer) ERC721Impl(_name, _symbol) {
        signer = _signer;
    }

    // _account: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // _tokenId: 0
    // _signature: 0x390d704d7ab732ce034203599ee93dd5d3cb0d4d1d7c600ac11726659489773d559b12d220f99f41d17651b0c1c6a669d346a397f8541760d6b32a5725378b241c
    // 调用前已经完成了签名，链上只需要验证签名正确，就可以进行铸造NFT
    function mint(address _account, uint256 _tokenId, bytes memory _signature) external {
        bytes32 _msgHash = getMessageHash(_account, _tokenId);
        bytes32 _ethSignedMessageHash = ECDSA.toEthSignedMessageHash(_msgHash);
        require(verify(_ethSignedMessageHash, _signature), "Invalid signature");
        _mint(_account, _tokenId);
        mintedAddress[_account] = true;
    }

    function getMessageHash(address _account, uint256 _tokenId) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_account, _tokenId));
    }

    function verify(bytes32 _msgHash, bytes memory _signature) public view returns (bool) {
        return ECDSA.verify(_msgHash, _signature, signer);
    }
}