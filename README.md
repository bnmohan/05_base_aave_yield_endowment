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

5. **2-Stage Dynamic Action Button**:
   - **Step 1: Approve USDC (1-Time)**: Requests 1-time `MaxUint256` approval so users never have to sign approval transactions again.
   - **Step 2: Deposit & Earn Yield**: Automatically activates upon approval block confirmation (~2s) for direct 1-click deposits.

6. **Live Web3 Diagnostics Panel**:
   - Displays real-time Connected Wallet, MetaMask Chain ID, Resolved Environment, and Gateway Contract.

7. **Event-Driven Confirmations & Real-Time Logging**:
   - Parallel event stream listening directly to `event Deposited`, `event Approval`, `event PrincipalWithdrawn`, and `event YieldHarvested` on Base Sepolia.

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

## 🌐 Multi-Network Testing Guide

Start the local web server:
```bash
cd frontend
python3 -m http.server 8000
```

---

### Option A: Test Live on Base Sepolia Testnet

1. Open **[http://localhost:8000/?network=sepolia](http://localhost:8000/?network=sepolia)** in Chrome with MetaMask.
2. In MetaMask, select **Base Sepolia** (`Chain ID: 84532` / `0x14a34`).
3. **Import Test Tokens in MetaMask**:
   - **Aave Reserve USDC**: `0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f`
4. **Deposit & Harvest Flow**:
   - If first time: Click **`[ 🔓 Step 1: Approve USDC (1-Time) ]`** $\rightarrow$ Confirm in MetaMask.
   - The button flips to **`[ 💰 Deposit & Earn Yield for Cause ]`** $\rightarrow$ Click to deposit into Aave V3.
   - Under the **Harvest Yield** tab, click **Harvest Accrued Yield** to send earned yield to the campaign!

---

### Option B: Test Locally on Anvil Fork (Fast & Free)

1. **Launch the local Anvil fork**:
   ```bash
   anvil --fork-url https://base-sepolia-rpc.publicnode.com --chain-id 31337
   ```
2. Open **[http://localhost:8000/?network=anvil](http://localhost:8000/?network=anvil)** in Chrome with MetaMask.
3. In MetaMask, select **Localhost 8545** (`Chain ID: 31337` / `0x7a69`).
4. **Pre-funded Anvil Test Accounts**:
   - Account #0: `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`
   - Account #1: `0x70997970C51812dc3A010C7d01b50e0d17dc79C8`
5. **Tip (Clear MetaMask Nonce Cache on Anvil Restart)**:
   - If Anvil is restarted, clear MetaMask's local UI cache:
     *MetaMask $\rightarrow$ 3 dots $\rightarrow$ Settings $\rightarrow$ Advanced $\rightarrow$ **Clear activity tab data**.*

---

### Option C: Offline Interactive Simulation Mode

* Open **[http://localhost:8000](http://localhost:8000)** without query parameters.
* Test the complete endowment mechanics (Deposit, Principal Protection, Real-time Yield Growth Simulation, Harvesting) with zero wallet connection required!

---

## 📜 License
MIT License. Built for the Base Ecosystem.
