// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/interfaces/IERC4626.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

// 金库合约：DeFi乐高中的基础，把基础资产(代币)质押到合约中，换取份额，取得一定收益。
// - 收益农场：Yearn Finance，质押USDT获得利息。
// - 借贷：AAVE，出借ETH获取存款利息和贷款。
// - 质押：Lido，质押ETH参与ETH2.0质押，得到生息的stETH。

// ERC4626对于DeFi的重要性不亚于ERC721对于NFT的重要性。
// - 继承ERC20
// - 存款逻辑：存入资产
// - 提款逻辑：提取资产
// - 会计&限额逻辑


contract ERC4626 is ERC20, IERC4626 {

    ERC20 private immutable _asset;
    uint8 private immutable _decimals;

    constructor(ERC20 asset_, string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        _asset = asset_;
        _decimals = asset_.decimals();
    }

    // IERC4626 - 元数据
    function asset() public view virtual override returns (address) {
        return address(_asset);
    }

    // IERC20Metadata
    function decimals() public view virtual override(IERC20Metadata, ERC20) returns (uint8) {
        return _decimals;
    }

    // IERC4626 - 存款
    function deposit(uint256 assets, address receiver) public virtual override returns (uint256 shares) {
        shares = previewDeposit(assets);                            // 计算份额
        _asset.transferFrom(msg.sender, address(this), assets);     // 转入资产
        _mint(receiver, shares);                                    // 铸造份额[_mint方法实现位置?]ERC20
        emit Deposit(msg.sender, receiver, assets, shares);
    }
    function previewDeposit(uint256 assets) public view virtual override returns (uint256) {
        return convertToShares(assets);
    }

    // IERC4626 - 存款
    function mint(uint256 shares, address receiver) public virtual override returns (uint256 assets) {
        assets = previewMint(shares);                               // 计算资产
        _asset.transferFrom(msg.sender, address(this), assets);     // 转入资产
        _mint(receiver, shares);                                    // 铸造份额[_mint方法实现位置?]ERC20
        emit Deposit(msg.sender, receiver, assets, shares);
    }
    function previewMint(uint256 shares) public view virtual override returns (uint256) {
        return convertToAssets(shares);
    }

    // IERC4626 - 提款
    function withdraw(uint256 assets, address receiver, address owner) public virtual override returns (uint256 shares) {
        shares = previewWithdraw(assets);                           // 计算份额
        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);             // 更新授权[方法实现位置?]ERC20
        }
        _burn(owner, shares);                                       // 销毁份额
        _asset.transfer(receiver, assets);                          // 返还资产
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }
    function previewWithdraw(uint256 assets) public view virtual override returns (uint256) {
        return convertToShares(assets);
    }

    // IERC4626 - 提款
    function redeem(uint256 shares, address receiver, address owner) public virtual override returns (uint256 assets) {
        assets = previewRedeem(shares);                             // 计算资产
        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }
        _burn(owner, shares);                                       // 销毁份额
        _asset.transfer(receiver, assets);                          // 返还资产
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }
    function previewRedeem(uint256 shares) public view virtual override returns (uint256) {
        return convertToAssets(shares);
    }

    // IERC4626 - 限额
    function maxDeposit(address) public view virtual override returns (uint256) {
        return type(uint256).max;
    }
    function maxMint(address) public view virtual override returns (uint256) {
        return type(uint256).max;
    }
    function maxWithdraw(address owner) public view virtual override returns (uint256) {
        return convertToAssets(balanceOf(owner));
    }
    function maxRedeem(address owner) public view virtual override returns (uint256) {
        return balanceOf(owner);
    }

    // IERC4626 - 会计逻辑
    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply();                             // [方法实现位置?]ERC20
        return supply == 0 ? assets : assets * supply / totalAssets();
    }
    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply();                             // [方法实现位置?]ERC20
        return supply == 0 ? shares : shares * totalAssets() / supply;
    }
    function totalAssets() public view virtual returns (uint256) {
        return _asset.balanceOf(address(this));
    }
}

// 此合约实现的是资产和份额的1:1转换逻辑