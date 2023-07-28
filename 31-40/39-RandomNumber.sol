// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/smartcontractkit/chainlink-brownie-contracts/blob/main/contracts/src/v0.8/VRFConsumerBase.sol";
import "31-40/34-ERC721.sol";

/* WARN: 预言机挖矿执行失败，前两天还是成功的，WTF git上的代码也失败，应该是VRF的原因，后面再看。*/


// 随机数用途：随机tokenId、抽盲盒、游戏随机胜负等
// 链上随机数：特定链上数据取哈希
// 链下随机数：ChainLink预言机

// 准备内容：
// 1. https://docs.chain.link/vrf/v2/direct-funding/supported-networks#sepolia-testnet, 点击LINK Token的<Add to wallet>按钮，将LINK代币添加到MetaMask钱包Sepolia测试网账户中
// 2. https://faucets.chain.link/sepolia, 利用LINK的faucet获取测试使用的token，注意地址填钱包地址，并通过twitter登录（一小时只能获取一次）
// 3. 部署合约
// 4. 在MetaMask中将LINK Token转到合约地址中进行使用，转1个试试

// 使用随机tokenId铸造NFT）
contract Random is ERC721Impl, VRFConsumerBase {
    uint256 public totalSupply = 100;   // 总供给
    uint256[100] public ids;            // 可供mint的tokenId
    uint256 public mintCount;           // 已mint数量

    // VRF信息（Sepolia测试链：https://docs.chain.link/vrf/v2/direct-funding/supported-networks#sepolia-testnet）
    bytes32 internal keyHash;       // 唯一标识符，ID of public key against which randomness is generated
    uint256 internal fee;           // 使用费

    mapping(bytes32 => address) public requestToSender;

    constructor() VRFConsumerBase(
        // VRF信息（Sepolia测试链：https://docs.chain.link/vrf/v2/direct-funding/supported-networks#sepolia-testnet）
        0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,     // VRF Coordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625 (for Sepolia)
        0x779877A7B0D9E8603169DdbD7836e478b4624789      // LINK Token: 0x779877A7B0D9E8603169DdbD7836e478b4624789 (for Sepolia)
    ) ERC721Impl("WTF Random1", "WTF1") {
        // 30 gwei key hash ?
        keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;   // ID of public key against which randomness is generated
        fee = 0.5 * 10 ** 18;                          // Coordiantor Flat Fee: 0.25 LINK (for Sepolia)
    }

    // 【链上随机数】利用区块ID、地址、区块Hash获取链上随机数
    // 同一个区块、同一个地址多次调用返回相同结果，因为使用的都是持久到链上的不变数据
    // 不安全：可预测、可操纵
    function getRandomOnChain() public view returns (uint256) {
        bytes32 randomBytes = keccak256(abi.encodePacked(block.number, msg.sender, blockhash(block.timestamp - 1)));
        return uint256(randomBytes);
    }

    // 【链下随机数】利用ChainLink的VRF预言机获取随机数
    function mintRandomVRF() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        requestId = requestRandomness(keyHash, fee);    // 利用预言机计算随机数
        requestToSender[requestId] = msg.sender;
        return requestId;
    }

    // 预言机触发函数调用，自动进行NFT的铸造
    // Once the VRFCoordinator has received and validated the oracle's response
    // to your request, it will call your contract's fulfillRandomness method.
    // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
    // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
    // the origin of the call
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        address sender = requestToSender[requestId];
        uint256 _tokenId = pickRandomUniqueId(randomness);
        _mint(sender, _tokenId);
    }

    // 利用链上随机数铸造NFT
    function mintRandomOnChain() public {
        uint256 _tokenId = pickRandomUniqueId(getRandomOnChain());
        _mint(msg.sender, _tokenId);
    }

    /*
    算法过程可理解为：totalSupply个空杯子（0初始化的ids）排成一排，每个杯子旁边放一个球，编号为[0, totalSupply - 1]。
    每次从场上随机拿走一个球（球可能在杯子旁边，这是初始状态；也可能是在杯子里，说明杯子旁边的球已经被拿走过，则此时新的球从末尾被放到了杯子里）
    再把末尾的一个球（依然是可能在杯子里也可能在杯子旁边）放进被拿走的球的杯子里，循环totalSupply次。相比传统的随机排列，省去了初始化ids[]的gas。
    */
    function pickRandomUniqueId(uint256 random) private returns (uint256 tokenId) {
        // 计算随机数对应的索引
        uint256 len = totalSupply - mintCount++;
        require(len > 0, "mint close");
        uint256 randomIndex = random % len;

        // 如果存在预设的tokenId，则使用，否则就用索引ID（预设值是根据长度填充的，必然不等于索引，也必然未被使用，是唯一tokenId）
        tokenId = ids[randomIndex] != 0 ? ids[randomIndex] : randomIndex;
        // 将末尾位置的值移动到索引位置
        ids[randomIndex] = ids[len - 1] == 0 ? len - 1 : ids[len - 1];
        // 删除末尾的无用元素
        ids[len - 1] = 0;

        // 最终的TokenID范围依然是0~totalSupply-1，此处的处理方式是不进行数组初始化的情况下，保证随机性和唯一性
    }
}