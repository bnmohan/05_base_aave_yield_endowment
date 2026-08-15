# 🌾 Aave Yield Savings Endowment Gateway

[![Base Sepolia](https://img.shields.io/badge/Network-Base_Sepolia-blue?logo=ethereum)](#)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.24-lightgrey?logo=solidity)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Framework-Foundry-orange)](https://getfoundry.sh/)
[![Aave](https://img.shields.io/badge/DeFi-Aave_V3_Yield-red)](https://aave.com)

> **Decentralized, yield-bearing savings endowment gateway on Base L2 that pools stablecoin deposits into Aave V3 lending pools to generate continuous yield for public campaigns.**

---

## 🌟 Executive Overview & Web3 Paradigm Aim

Traditional donation models suffer from capital depreciation and one-time value transfers:
1. **Donor Capital Depletion**: Donors lose their principal capital forever when donating to campaigns, limiting their capacity for repeat support.
2. **Idle Capital Inefficiencies**: Crowdfunded capital sits idle in multi-sig wallets awaiting disbursement, missing out on interest yield.

### The Plug-and-Play Solution: Yield-Bearing Endowments
This repository provides a **yield-bearing savings endowment gateway** integrated with **Aave V3**. Donors lock stablecoin deposits (e.g., USDC) into the endowment contract. The contract pools this capital and supplies it to the Aave lending pool. The interest yield generated (via interest-bearing aTokens) is automatically directed to support campaigns, while donors retain the ability to withdraw their original principal.

---

## 🔬 Key Web3 Technical Concepts & Architecture

### 1. Liquidity Pool Integrations (Aave V3)
- **Pool Supply Execution**: Deposited stablecoins are forwarded to the Aave pool via the `supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode)` function.
- **aToken Accrual**: The endowment contract receives yield-generating interest-bearing tokens (aTokens) at a 1:1 ratio. The balance of aTokens grows continuously based on the pool's lending rate.

### 2. Yield Separation (Principal vs. Interest)
- **Principal Integrity**: The contract enforces that the user's initial deposit cannot be touched by anyone other than the depositor.
- **Yield Harvesting**: The difference between the contract's total aToken balance and the sum of all deposited principals represents accrued yield, which is harvested and routed to designated campaigns.

### 3. High Performance on Base
- Low L2 gas costs on Base make frequent yield updates, harvests, and withdrawals highly cost-effective.

---

## 📍 Live On-Chain Deployments (Base Sepolia Testnet)

| Contract | Network | Deployed Address | Block Explorer |
| :--- | :--- | :--- | :--- |
| **`YieldEndowment`** | **Base Sepolia** | *TBD (Pending Deployment)* | [View on BaseScan](#) |

- **Deployment Tx Hash**: *TBD (Pending Deployment)*

---

## 🛠️ Project Architecture & Data Schema

```
05_base_aave_yield_endowment/
├── README.md                               # Project documentation
├── .gitignore                              # Root git ignore file
├── contracts/
│   ├── src/
│   │   ├── interfaces/
│   │   │   └── IPool.sol                   # Aave V3 Pool interface
│   │   ├── mocks/
│   │   │   └── MockAavePool.sol            # Mock lending pool for local testing
│   │   └── YieldEndowment.sol              # Core yield endowment logic
│   ├── test/
│   │   └── YieldEndowment.t.sol            # Automated Forge unit test suite
│   ├── script/
│   │   └── Deploy.s.sol                    # Solidity deployment script
│   ├── foundry.toml                        # Forge compilation settings
│   └── .env                                # Protected deployment key storage
└── frontend/
    └── index.html                          # Glassmorphic Dapp gateway UI
```

### On-Chain Data Schema (`YieldEndowment.sol`)
* `aavePool`: The Aave V3 Liquidity Pool address.
* `underlyingAsset`: The address of the stablecoin supplied (e.g. USDC).
* `aToken`: The interest-bearing token representing Aave deposits.
* `userPrincipals[address => uint256]`: Records the principal amount deposited by each donor.
* `harvestYield()`: Directs accrued interest to the designated beneficiary campaign.

---

## 🧰 Technology Stack

- **Smart Contracts**: Solidity `^0.8.24`
- **Development & Testing**: Foundry (`forge`, `cast`)
- **DeFi Protocol**: Aave V3 Protocol Core
- **Blockchain Network**: Base Sepolia Testnet (Chain ID `84532`)
- **Frontend Dapp**: Vanilla HTML5 / Modern CSS3 (Glassmorphism), Ethers.js `v6`

---

## 🚀 Quickstart & Local Setup

To easily set up this repository in standalone mode (configure environment files, install local dependencies, and compile contracts in one click), run:
```bash
chmod +x setup.sh
./setup.sh
```


### 1. Smart Contract Compilation & Unit Tests
```bash
cd contracts

# Compile Solidity contracts
forge build

# Run automated unit tests
forge test -vv
```

### 2. Deploying to Base Sepolia
```bash
cd contracts

# Set environment variables:
# PRIVATE_KEY=your_private_key_here
# BASE_SEPOLIA_RPC_URL=your_base_sepolia_rpc_url_here

# Deploy the contract using Foundry script
forge script script/Deploy.s.sol:DeployScript --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast --verify -vvvv
```

### 3. Launching the Web Dapp
```bash
# Serve frontend folder via HTTP
cd frontend
python3 -m http.server 8000
```
Open **[http://localhost:8000](http://localhost:8000)** in Google Chrome, connect MetaMask to Base Sepolia, and interact with the endowment dashboard!

---

## 📜 License
MIT License. Built with ❤️ for the Base Ecosystem.
