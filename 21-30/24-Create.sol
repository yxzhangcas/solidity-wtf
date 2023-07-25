// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// 智能合约可以创建新的智能合约，两种方法：create和create2
// Contract x = new Contract{value: _value}(params)
// value：向payable的构造函数发送ETH，params：向带有参数的构造函数传参
// 在之前的例子中已经用过了，见：18-Import.sol

contract Pair {
    address public factory; //工厂合约地址
    address public token0;  //代币1
    address public token1;  //代币2

    constructor() payable {
        factory = msg.sender;   //创建此合约的地址
    }

    // 只调用一次进行初始化
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, "UniswapV2: FORBIDDEN");
        token0 = _token0;
        token1 = _token1;
    }

    //可以在constructor中传参进行实现初始化，create允许构造函数带参数，create2不允许
    // constructor(address _token0, address _token1) payable {
    //     factory = msg.sender;
    //     token0 = _token0;
    //     token1 = _token1;
    // }
}

contract PairFactory {
    mapping(address => mapping(address => address)) public getPair; //通过两个代币地址查询pair地址
    address[] public allPairs;  //所有的pair地址

    // 0x2c44b726ADF1963cA47Af88B284C06f30380fC78
    // 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    function createPair(address tokenA, address tokenB) external returns (address pairAddr) {
        Pair pair = new Pair();     //每次调用创建新的合约(区块链浏览器的内部合约可以看到)
        pair.initialize(tokenA, tokenB);
        pairAddr = address(pair);   //返回值

        allPairs.push(pairAddr);    //数组用push
        getPair[tokenA][tokenB] = pairAddr;     //map用索引
        getPair[tokenB][tokenA] = pairAddr;
    }
}