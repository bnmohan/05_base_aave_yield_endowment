// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IPool.sol";
import "./MockERC20.sol";
import "./MockAToken.sol";

/// @notice Mock Aave V3 Liquidity Pool for testing deposits, withdrawals, and yield accrual
contract MockAavePool is IPool {
    MockERC20 public immutable underlyingAsset;
    MockAToken public immutable aToken;

    constructor(address _underlyingAsset, address _aToken) {
        underlyingAsset = MockERC20(_underlyingAsset);
        aToken = MockAToken(_aToken);
    }

    /// @notice Supply underlying asset into Mock Aave pool, minting aTokens to onBehalfOf
    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 /* referralCode */
    ) external override {
        require(asset == address(underlyingAsset), "MockAavePool: Unsupported asset");
        require(amount > 0, "MockAavePool: Amount must be > 0");

        // Transfer underlying token from caller to pool
        bool success = underlyingAsset.transferFrom(msg.sender, address(this), amount);
        require(success, "MockAavePool: Transfer failed");

        // Mint aTokens to specified recipient
        aToken.mint(onBehalfOf, amount);
    }

    /// @notice Withdraw underlying asset from Mock Aave pool, burning equivalent aTokens
    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external override returns (uint256) {
        require(asset == address(underlyingAsset), "MockAavePool: Unsupported asset");
        require(amount > 0, "MockAavePool: Amount must be > 0");

        uint256 callerBalance = aToken.balanceOf(msg.sender);
        uint256 amountToWithdraw = amount > callerBalance ? callerBalance : amount;

        // Burn caller's aTokens
        aToken.burn(msg.sender, amountToWithdraw);

        // Transfer underlying token to destination address
        bool success = underlyingAsset.transfer(to, amountToWithdraw);
        require(success, "MockAavePool: Underlying transfer failed");

        return amountToWithdraw;
    }

    /// @notice Helper for tests: simulates interest accrued on aTokens for holder
    function simulateYield(address holder, uint256 yieldAmount) external {
        // Mint extra aTokens to holder to represent yield
        aToken.mint(holder, yieldAmount);
        // Mint underlying tokens to pool to back the new aTokens
        underlyingAsset.mint(address(this), yieldAmount);
    }
}
