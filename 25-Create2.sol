// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// create2 可以在智能合约部署之前便预测出合约的地址！！！

// create地址生成方式：hash(创建者地址, nonce) - nonce递增无法确定性预测
// create2地址生成方式：hash('0xFF', 创建者地址, salt, 合约字节码)

// create创建合约方式：Contract x = new Contract{value: _value}(params)
// create2创建合约方式：Contract x = new Contract{salt: _salt, value: _value}(params)   //需要多传入一个salt值

// 在合约部署前获知地址信息，是Layer2项目的基础

contract Pair{
    address public factory; // 工厂合约地址
    address public token0; // 代币1
    address public token1; // 代币2

    constructor() payable {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, 'UniswapV2: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }
}

contract PairFactory2 {
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    // 0x2c44b726ADF1963cA47Af88B284C06f30380fC78
    // 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    function createPair2(address tokenA, address tokenB) external returns (address pairAddr) {
        require(tokenA != tokenB, "IDENTICAL_ADDRESSES");   //避免冲突

        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));  //确定性计算salt(bytes32)

        Pair pair = new Pair{salt: salt}(); //通过create2部署
        pair.initialize(tokenA, tokenB);
        pairAddr = address(pair);

        allPairs.push(pairAddr);
        getPair[tokenA][tokenB] = pairAddr;
        getPair[tokenB][tokenA] = pairAddr;
    }

    //部署前计算pair的地址
    // 0x9d514b34CE41A48B270C4151044AC9bCB220C09B [会随着代码变化造成字节码编码最终而变化]
    function calculateAddr(address tokenA, address tokenB) public view returns (address predictedAddr) {
        require(tokenA != tokenB, "IDENTICAL_ADDRESSES");

        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));  //确定性计算salt(bytes32)

        predictedAddr = address(uint160(uint(
            keccak256(abi.encodePacked(
                bytes1(0xFF),       // bytes1
                address(this),
                salt,
                keccak256(type(Pair).creationCode)  //合约字节码！！！
            ))
        )));
    }
}