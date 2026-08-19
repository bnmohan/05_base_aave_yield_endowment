# 🌾 Aave Yield Savings Endowment Gateway

[![Base Sepolia](https://img.shields.io/badge/Network-Base_Sepolia-blue?logo=ethereum)](https://sepolia.basescan.org/address/0xE41Be53B79370CCe5a2Ecb65706528FbCa120648)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.24-lightgrey?logo=solidity)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Framework-Foundry-orange)](https://getfoundry.sh/)
[![Aave V3](https://img.shields.io/badge/DeFi-Aave_V3_Yield-red)](https://aave.com)

> **Decentralized, loss-protected savings endowment gateway on Base L2 that pools stablecoin deposits into Aave V3 lending pools to generate continuous, perpetual yield for public campaigns while preserving 100% of donor principal.**

---

## 🌟 Executive Overview & Web3 Paradigm

Traditional donation models suffer from capital depletion and one-time value transfers:
1. **Donor Capital Depletion**: Donors lose their principal capital forever when donating to causes, limiting their capacity for repeat support.
2. **Idle Capital Inefficiencies**: Crowdfunded capital sits idle in multi-sig wallets awaiting disbursement, missing out on real-time DeFi yield.

### The Solution: Principal-Protected Yield Endowments
This project provides a **yield-bearing savings endowment gateway** integrated with **Aave V3**. 
* Donors deposit stablecoins (e.g. USDC).
* The gateway supplies the pooled capital to Aave V3 lending pools on Base.
* The interest yield generated (via interest-bearing `aTokens`) can be harvested in full or in custom partial amounts to support designated campaigns.
* Donors can withdraw their original principal at any time with zero loss.

---

## 📍 Live On-Chain Deployments (Base Sepolia Testnet)

| Contract | Network | Deployed Address | Block Explorer |
| :--- | :--- | :--- | :--- |
| **`YieldEndowment` Core Gateway** | **Base Sepolia (84532)** | `0xE41Be53B79370CCe5a2Ecb65706528FbCa120648` | [View on BaseScan](https://sepolia.basescan.org/address/0xE41Be53B79370CCe5a2Ecb65706528FbCa120648) |
| **Aave V3 Pool Proxy** | **Base Sepolia (84532)** | `0x8bAB6d1b75f19e9eD9fCe8b9BD338844fF79aE27` | [View on BaseScan](https://sepolia.basescan.org/address/0x8bAB6d1b75f19e9eD9fCe8b9BD338844fF79aE27) |
| **Aave Testnet USDC** | **Base Sepolia (84532)** | `0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f` | [View on BaseScan](https://sepolia.basescan.org/address/0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f) |
| **Aave aUSDC Token** | **Base Sepolia (84532)** | `0x10F1A9D11CDf50041f3f8cB7191CBE2f31750ACC` | [View on BaseScan](https://sepolia.basescan.org/address/0x10F1A9D11CDf50041f3f8cB7191CBE2f31750ACC) |

---

## 🔬 Core Features & Smart Contract Mechanics

1. **Deposit & Principal Protection (`deposit(uint256 amount)`)**:
   - Pulls stablecoins from the donor, approves Aave V3, and supplies capital into the lending reserve.
   - Updates `userPrincipals[donor]` and `totalPrincipal` accounting invariants.

2. **Principal Withdrawal (`withdrawPrincipal(uint256 amount)`)**:
   - Allows donors to redeem their deposited principal back to their wallet at any time.
   - Enforces that no user can withdraw more than their recorded deposit.

3. **Full & Partial Yield Harvesting**:
   - **`harvestYield()`**: Harvests 100% of all accrued Aave lending interest yield directly to the campaign beneficiary.
   - **`harvestYieldAmount(uint256 amount)`**: Allows harvesting a specific custom amount of accrued yield (e.g. 25%, 50%, or exact amount), leaving remaining yield compounding in the pool.

4. **Campaign Beneficiary Governance (`setBeneficiary(address newBeneficiary)`)**:
   - Allows the contract owner to dynamically update the receiving cause address without affecting active deposits.

5. **Dual-Network Architecture (`frontend/config.js`)**:
   - Out-of-the-box support for both **Base Sepolia Testnet (84532)** and **Local Anvil Fork (31337)**.

---

## 🛠️ Project Structure

```
05_base_aave_yield_endowment/
├── README.md                               # Project documentation
├── setup.sh                                # Automated toolchain & dependency installer
├── .gitignore                              # Protected git ignore rules
├── contracts/
│   ├── src/
│   │   ├── interfaces/
│   │   │   └── IPool.sol                   # Aave V3 Pool, ERC20 & aToken interfaces
│   │   ├── mocks/
│   │   │   ├── MockERC20.sol               # Mintable test token
│   │   │   ├── MockAToken.sol              # Interest-bearing token mock
│   │   │   └── MockAavePool.sol            # Standalone lending pool mock with yield simulation
│   │   └── YieldEndowment.sol              # Core yield endowment gateway contract
│   ├── test/
│   │   └── YieldEndowment.t.sol            # 10/10 Foundry automated test suite
│   ├── script/
│   │   └── Deploy.s.sol                    # Solidity deployment script with pre-deploy validation
│   ├── foundry.toml                        # Foundry toolchain settings
│   └── .env.example                        # Deployment environment template
└── frontend/
    ├── config.js                           # Dual-Network Web3 configuration registry
    └── index.html                          # Glassmorphic Web3 Dapp gateway UI
```

---

## 🚀 Quickstart Guide

### 1. Automated Setup (1-Click)
Run the setup script to verify Foundry toolchain, install dependencies, and compile all contracts:
```bash
chmod +x setup.sh
./setup.sh
```

### 2. Run Automated Unit Tests
```bash
cd contracts
forge test -v
```
*(All 10 unit tests will run and pass)*

---

## 🌐 How to Test the Prototype

### Option A: Test Live on Base Sepolia (Recommended)
1. **Launch the Web Dapp**:
   ```bash
   cd frontend
   python3 -m http.server 8000
   ```
2. Open **[http://localhost:8000](http://localhost:8000)** in Chrome with MetaMask.
3. Switch MetaMask to **Base Sepolia Testnet**.
4. Claim test tokens:
   - Base Sepolia ETH from [Alchemy Faucet](https://www.alchemy.com/faucets/base-sepolia) or [Superchain Faucet](https://console.optimism.io/faucet).
   - Aave Testnet USDC (`0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f`) from the [Aave Base Sepolia Faucet Contract](https://sepolia.basescan.org/address/0xD9145b5F45Ad4519c7ACcD6E0A4A82e83bB8A6Dc#writeContract).
5. Deposit USDC, watch live Aave yield accrue, and test harvesting and withdrawals on-chain!

---

### Option B: Test Locally on Anvil Fork (Fast & Free)
1. **Launch the local Anvil fork**:
   ```bash
   anvil --fork-url https://base-sepolia-rpc.publicnode.com --chain-id 31337
   ```

2. **Launch the Web Dapp**:
   ```bash
   cd frontend
   python3 -m http.server 8000
   ```
3. Connect MetaMask to **Localhost 8545 (Chain ID 31337)**.
4. Because Anvil forks Base Sepolia, the deployed contract [`0xE41Be53B...`](https://sepolia.basescan.org/address/0xE41Be53B79370CCe5a2Ecb65706528FbCa120648) and Aave V3 are already live in your local environment with instant 0-second confirmation!

---

## 📜 License
MIT License. Built for the Base Ecosystem.
