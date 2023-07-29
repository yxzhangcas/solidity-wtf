// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// 所有的执行都必须加入队列，然后由合约从队列中取出操作进行call执行，外部账户无法执行任何的实际功能，都依赖合约


contract TimeLock {
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint executeTime);
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint executeTime);
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint executeTime);
    event NewAdmin(address indexed newAdmin);

    address public admin;                       // 管理员地址
    uint public delay;                          // 交易锁定时间
    mapping(bytes32 => bool) public queuedTransactions; // 所有在时间队列中的交易

    uint public constant GRACE_PERIOD = 7 days; // 交易有效期

    modifier onlyOwner() {
        require(msg.sender == admin, "TimeLock: Caller not admin");
        _;
    }
    modifier onlyTimeLock() {
        require(msg.sender == address(this), "TimeLock: Caller not Timelock");
        _;
    }

    constructor(uint delay_) {
        delay = delay_;
        admin = msg.sender;
    }
    // 由TimeLock合约变更管理员
    function changeAdmin(address newAdmin) public onlyTimeLock {
        admin = newAdmin;
        emit NewAdmin(newAdmin);
    }
    // 创建交易，添加到时间锁队列
    function queueTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime) public onlyOwner returns (bytes32) {
        require(executeTime >= getBlockTimestamp() + delay, "TimeLock::queueTransaction: Estimated execution block must satisfy delay.");
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        queuedTransactions[txHash] = true;
        emit QueueTransaction(txHash, target, value, signature, data, executeTime);
        return txHash;
    }
    // 取消特定交易
    function cancelTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime) public onlyOwner {
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        require(queuedTransactions[txHash], "TimeLock::cancelTransaction: Transaction hasn't been queued.");
        queuedTransactions[txHash] = false;
        emit CancelTransaction(txHash, target, value, signature, data, executeTime);
    }
    // 执行特定交易
    function executeTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime) public payable onlyOwner returns (bytes memory) {
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        require(queuedTransactions[txHash], "TimeLock::executeTransaction: Transaction hasn't been queued.");
        require(getBlockTimestamp() >= executeTime, "TimeLock::executeTransaction: Transaction hasn't surpassed time lock");
        require(getBlockTimestamp() <= executeTime + GRACE_PERIOD, "TimeLock::executeTransaction: Transaction is stale.");
        queuedTransactions[txHash] = false;

        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }
        // 使用call方法执行实际合约
        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, "TimeLock::executeTransaction: Transaction execution reverted.");
        emit ExecuteTransaction(txHash, target, value, signature, data, executeTime);
        return returnData;
    }

    function getBlockTimestamp() public view returns (uint) {
        return block.timestamp;
    }
    function getTxHash(address target, uint value, string memory signature, bytes memory data, uint executeTime) public pure returns (bytes32) {
        return keccak256(abi.encode(target, value, signature, data, executeTime));
    }
}

// 1. 部署合约：delay = 120
// 2. 地址编码格式化填充：https://abi.hashex.org/，0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 => 0x000000000000000000000000ab8483f64d9c6d1ecf9b849ae677dd3315835cb2
// 3. 切换测试账号调用changeAdmin报错（调用方非当前合约，故需要通过队列交易的方式进行切换）
// 4. queueTransaction: 合约地址、0、"changeAdmin(address)"、0x000000000000000000000000ab8483f64d9c6d1ecf9b849ae677dd3315835cb2、getBlockTimestamp() + 200[必须大于delay]
// 5. executeTransaction: 相同参数，等待足够的时间才能执行
