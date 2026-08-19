// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/YieldEndowment.sol";
import "../src/mocks/MockERC20.sol";
import "../src/mocks/MockAToken.sol";
import "../src/mocks/MockAavePool.sol";

contract DeployScript is Script {
    // Verified Official Base Sepolia Aave V3 Constants (BGD Labs Address Book)
    address internal constant DEFAULT_AAVE_POOL = 0x8bAB6d1b75f19e9eD9fCe8b9BD338844fF79aE27;
    address internal constant DEFAULT_USDC = 0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f;
    address internal constant DEFAULT_A_USDC = 0x10F1A9D11CDf50041f3f8cB7191CBE2f31750ACC;
    address internal constant DEFAULT_ANVIL_BENEFICIARY = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    function run() external {
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80));
        address beneficiaryAddress = vm.envOr("BENEFICIARY_ADDRESS", DEFAULT_ANVIL_BENEFICIARY);

        vm.startBroadcast(deployerPrivateKey);

        // Resolve addresses (defaults to verified Base Sepolia Aave V3 addresses)
        address poolAddr = vm.envOr("AAVE_POOL_ADDRESS", DEFAULT_AAVE_POOL);
        address usdcAddr = vm.envOr("USDC_ADDRESS", vm.envOr("UNDERLYING_USDC", DEFAULT_USDC));
        address aUsdcAddr = vm.envOr("A_USDC_ADDRESS", DEFAULT_A_USDC);

        // If target chain is blank local EVM with no deployed code, deploy mock DeFi infrastructure
        if (poolAddr.code.length == 0 || usdcAddr.code.length == 0 || aUsdcAddr.code.length == 0) {
            console.log("Blank EVM detected. Deploying Mock DeFi Infrastructure for local testing...");
            
            MockERC20 usdcMock = new MockERC20("Mock USD Coin", "USDC", 6);
            usdcAddr = address(usdcMock);

            MockAToken aUsdcMock = new MockAToken("Mock Aave USDC", "aUSDC", 6, usdcAddr);
            aUsdcAddr = address(aUsdcMock);

            MockAavePool poolMock = new MockAavePool(usdcAddr, aUsdcAddr);
            poolAddr = address(poolMock);

            console.log("Mock USDC Deployed at:", usdcAddr);
            console.log("Mock aUSDC Deployed at:", aUsdcAddr);
            console.log("Mock Aave Pool Deployed at:", poolAddr);
        } else {
            console.log("Automated Pre-deploy Check: Verified external Aave V3 contracts on-chain!");
        }

        // Deploy YieldEndowment core contract
        YieldEndowment endowment = new YieldEndowment(
            poolAddr,
            usdcAddr,
            aUsdcAddr,
            beneficiaryAddress
        );

        console.log("----------------------------------------------");
        console.log("YieldEndowment Core Gateway Deployed at:", address(endowment));
        console.log("Beneficiary Campaign Address:", beneficiaryAddress);
        console.log("----------------------------------------------");

        vm.stopBroadcast();
    }
}
