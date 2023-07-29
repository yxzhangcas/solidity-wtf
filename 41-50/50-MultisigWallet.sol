// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MultisigWallet {

    event ExecutionSuccess(bytes32 txHash);     // 交易成功
    event ExecutionFailure(bytes32 txHash);     // 交易失败

    address[] public owners;                    // 多签持有人
    mapping(address => bool) public isOwner;    // 地址是否多签持有人
    uint256 public ownerCount;                  // 多签持有人数量
    uint256 public threshold;                   // 多签执行门槛，至少多少签名
    uint256 public nonce;                       // 防止重放攻击

    constructor(address[] memory _owners, uint256 _threshold) {
        _setupOwners(_owners, _threshold);
    }

    receive() external payable {}

    function execTransaction(address to, uint256 value, bytes memory data, bytes memory signatures) public payable virtual returns (bool success) {
        bytes32 txHash = encodeTransactionData(to, value, data, nonce, block.chainid);
        nonce++;
        checkSignature(txHash, signatures);
        (success, ) = to.call{value: value}(data);
        require(success, "WTF5004");
        if (success)
            emit ExecutionSuccess(txHash);
        else 
            emit ExecutionFailure(txHash);
    }

    // 检查交易签名
    function checkSignature(bytes32 dataHash, bytes memory signatures) public view {
        uint256 _threshold = threshold;
        require(_threshold > 0, "WTF5005");
        require(signatures.length >= _threshold * 65, "WTF5006");    // 足够多的人签名

        address lastOwner = address(0);
        address currentOwner;
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 i;
        for (i = 0; i < _threshold; i++) {
            (v, r, s) = signatureSplit(signatures, i);
            currentOwner = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", dataHash)), v, r, s);
            require(currentOwner > lastOwner && isOwner[currentOwner], "WTF5007");  // 签名从小到大顺序排列
            lastOwner = currentOwner;
        }
    }

    // 从打包签名中分离单个签名
    function signatureSplit(bytes memory signatures, uint256 pos) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        assembly {
            let signaturePos := mul(0x41, pos)
            r := mload(add(signatures, add(signaturePos, 0x20)))                // bytes32 r
            s := mload(add(signatures, add(signaturePos, 0x40)))                // bytes32 s
            v := and(mload(add(signatures, add(signaturePos, 0x41))), 0xff)     // uint8   v
        }
    }

    // 计算交易的hash，用于进行链下的多重签名和签名检查
    function encodeTransactionData(address to, uint256 value, bytes memory data, uint256 _nonce, uint256 chainId) public pure returns (bytes32) {
        return keccak256(abi.encode(to, value, keccak256(data), _nonce, chainId));
    }

    function _setupOwners(address[] memory _owners, uint256 _threshold) internal {
        require(threshold == 0, "WTF5000");                 // 门槛尚未初始化过
        require(_threshold <= _owners.length, "WTF5001");   // 门槛不超过人数
        require(_threshold >= 1, "WTF5002");                // 门槛至少为1

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0) && owner != address(this) && !isOwner[owner], "WTF5003");   // 持有人不能为0地址、本合约，不能重复
            owners.push(owner);
            isOwner[owner] = true;
        }
        ownerCount = _owners.length;
        threshold = _threshold;
    }
}

// 1. 部署合约：2个多签地址，门槛为2。（这两个多签地址就是Remix自带测试账号的地址的前两个）
//      多签地址1: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//      多签地址2: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// 2. 向合约转账1ETH: low level interactions
// 3. 调用encode函数，生成交易哈希，向多签地址1转账1ETH
//      to: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//      value: 1000000000000000000
//      data: 0x
//      _nonce: 0
//      chainid: 1
//      返回值: 0xb43ad6901230f2c59c3f7ef027c9a372f199661c61beeec49ef5a774231fc39b
// 4. 利用Remix的Account右侧签名按钮，使用两个多签地址为交易哈希签名
//      签名1: 0x014db45aa753fefeca3f99c2cb38435977ebb954f779c2b6af6f6365ba4188df542031ace9bdc53c655ad2d4794667ec2495196da94204c56b1293d0fbfacbb11c
//      签名2: 0xbe2e0e6de5574b7f65cad1b7062be95e7d73fe37dd8e888cef5eb12e964ddc597395fa48df1219e7f74f48d86957f545d0fbce4eee1adfbaff6c267046ade0d81c
//      两个签名拼接: 0x014db45aa753fefeca3f99c2cb38435977ebb954f779c2b6af6f6365ba4188df542031ace9bdc53c655ad2d4794667ec2495196da94204c56b1293d0fbfacbb11cbe2e0e6de5574b7f65cad1b7062be95e7d73fe37dd8e888cef5eb12e964ddc597395fa48df1219e7f74f48d86957f545d0fbce4eee1adfbaff6c267046ade0d81c
// 5. 执行transaction函数，使用上面的参数，执行后转账成功