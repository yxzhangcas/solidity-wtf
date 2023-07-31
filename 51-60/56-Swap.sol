// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// CPAMM, Constant Product Automated Market Maker, 恒定乘积自动做市商
// DEX, Distributed EXchange, 去中心化交易所，Uniswap/PancakeSwap
// AMM, Automated Market Maker, 自动做市商

// x: 可乐($COLA)总量
// y: 美元($USD)总量
// deltaX: 一笔交易可乐变化量
// deltaY: 一笔交易美元变化量
// L: 总流动性
// deltaL: 流动性变化量

// CSAMM, Constant Sum Automated Market Maker, 恒定总和自动做市商
// 约束条件：k = x + y, k 为常数
// 优点：代币价格稳定不变；缺点：流动性容易耗尽

// CPAMM
// 约束条件：k = x * y
// 优点：无限流动性，相对价格随买卖发生变化

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract SimpleSwap is ERC20 {
    IERC20 public token0;
    IERC20 public token1;

    uint public reserve0;
    uint public reserve1;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1);
    event Swap(address indexed sender, uint amountIn, address tokenIn, uint amountOut, address tokenOut);

    constructor(IERC20 _token0, IERC20 _token1) ERC20("SimpleSwap", "SS") {
        token0 = _token0;
        token1 = _token1;
    }

    // 流动性提供者(Liquidity Provider, LP)
    // 给市场提供流动性，并收取一定费用
    // 当用户向代币池添加流动性时，合约要记录添加的LP份额
    // 1. 首次添加流动性 deltaL = sqrt(deltaX * deltaY)
    // 2. 非首次添加 deltaL = L * min(deltaX/x, deltaY/y)
    
    // 增加流动性，转进代币，铸造LP
    function addLiquidity(uint amount0Desired, uint amount1Desired) public returns (uint liquidity) {
        // 转入token
        token0.transferFrom(msg.sender, address(this), amount0Desired);     // 将代币0转入Swap合约对应地址，提前进行转账授权
        token1.transferFrom(msg.sender, address(this), amount1Desired);     // 将代币1转入Swap合约对应地址，提前进行转账授权
        // 计算份额
        uint _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            liquidity = sqrt(amount0Desired * amount1Desired);              // 首次添加流动性
        } else {
            liquidity = min(amount0Desired * _totalSupply / reserve0, amount1Desired * _totalSupply / reserve1);        // 非首次添加
        }
        require(liquidity > 0, "Insufficient liquidity minted");
        // 更新储备
        reserve0 = token0.balanceOf(address(this));                         // 更新储备量
        reserve1 = token1.balanceOf(address(this));
        // 铸造代币
        _mint(msg.sender, liquidity);                                       // 铸造LP代币，代表流动性
        emit Mint(msg.sender, amount0Desired, amount1Desired);
    }

    // 移除流动性：deltaX = deltaL / L * x
    function removeLiquidity(uint liquidity) external returns (uint amount0, uint amount1) {
        // 获取余额
        uint balance0 = token0.balanceOf(address(this));
        uint balance1 = token1.balanceOf(address(this));
        // 计算转出代币数量
        uint _totalSupply = totalSupply();
        amount0 = liquidity * balance0 / _totalSupply;
        amount1 = liquidity * balance1 / _totalSupply;
        require(amount0 > 0 && amount1 > 0, "Insufficient liquidity bruned");
        // 销毁LP
        _burn(msg.sender, liquidity);
        // 转出代币
        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);
        // 更新储备
        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));
        emit Burn(msg.sender, amount0, amount1);
    }

    // swap代币
    function swap(uint amountIn, IERC20 tokenIn, uint amountOutMin) external returns (uint amountOut, IERC20 tokenOut) {
        require(amountIn > 0, "Insufficient output amount");
        require(tokenIn == token0 || tokenIn == token1, "Invalid token");

        uint balance0 = token0.balanceOf(address(this));
        uint balance1 = token1.balanceOf(address(this));

        if (tokenIn == token0) {        // 入0出1
            tokenOut = token1;
            amountOut = getAmountOut(amountIn, balance0, balance1);
            require(amountOut > amountOutMin, "Insufficient output amount");
            tokenIn.transferFrom(msg.sender, address(this), amountIn);      // 入0
            tokenOut.transfer(msg.sender, amountOut);                       // 出1
        } else {                        // 入1出0
            tokenOut = token0;
            amountOut = getAmountOut(amountIn, balance1, balance0);
            require(amountOut > amountOutMin, "Insufficient output amount");
            tokenIn.transferFrom(msg.sender, address(this), amountIn);      // 入1
            tokenOut.transfer(msg.sender, amountOut);                       // 出0
        }

        // 更新储备
        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));
        emit Swap(msg.sender, amountIn, address(tokenIn), amountOut, address(tokenOut));
    }







    // 交易额度计算公式
    // deltaX的token0，可以交换的token1数量：k = x * y; k = (x + deltaX) * (y + deltaY); deltaY = - deltaX * y / (x + deltaX)
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public pure returns (uint amountOut) {
        require(amountIn > 0, "Insufficient amount");
        require(reserveIn > 0 && reserveOut > 0, "Insufficient liquidity");
        amountOut = amountIn * reserveOut / (reserveIn + amountIn);
    }


    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }
}
