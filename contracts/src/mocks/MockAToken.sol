// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./MockERC20.sol";

/// @notice Mock Aave aToken implementing IAToken
contract MockAToken is MockERC20 {
    address public immutable UNDERLYING_ASSET_ADDRESS;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _underlying
    ) MockERC20(_name, _symbol, _decimals) {
        UNDERLYING_ASSET_ADDRESS = _underlying;
    }
}
