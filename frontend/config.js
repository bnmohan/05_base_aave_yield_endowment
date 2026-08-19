// Frontend Environment Configuration for Aave Yield Endowment Dapp
window.APP_CONFIG = {
  // Available Environments: Base Sepolia Testnet & Anvil Local Fork
  NETWORKS: {
    // Base Sepolia Testnet (Chain ID 84532 / 0x14a34)
    "0x14a34": {
      CHAIN_ID: "0x14a34",
      CHAIN_NAME: "Base Sepolia Testnet",
      RPC_URL: "https://base-sepolia-rpc.publicnode.com",
      BLOCK_EXPLORER: "https://sepolia.basescan.org",
      CONTRACT_ADDRESS: "0xE41Be53B79370CCe5a2Ecb65706528FbCa120648",
      USDC_ADDRESS: "0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f",
      A_USDC_ADDRESS: "0x10F1A9D11CDf50041f3f8cB7191CBE2f31750ACC",
      AAVE_POOL_ADDRESS: "0x8bAB6d1b75f19e9eD9fCe8b9BD338844fF79aE27"
    },
    // Anvil Local Fork of Base Sepolia (Chain ID 31337 / 0x7a69)
    "0x7a69": {
      CHAIN_ID: "0x7a69",
      CHAIN_NAME: "Anvil Local Fork",
      RPC_URL: "http://127.0.0.1:8545",
      BLOCK_EXPLORER: "https://sepolia.basescan.org",
      CONTRACT_ADDRESS: "0xE41Be53B79370CCe5a2Ecb65706528FbCa120648",
      USDC_ADDRESS: "0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f",
      A_USDC_ADDRESS: "0x10F1A9D11CDf50041f3f8cB7191CBE2f31750ACC",
      AAVE_POOL_ADDRESS: "0x8bAB6d1b75f19e9eD9fCe8b9BD338844fF79aE27"
    }
  },

  // Default Beneficiary Campaign
  DEFAULT_BENEFICIARY: "0x6F0190fB81cEd52C576501cE67a095b4f21Ea2F2",
  CAMPAIGN_NAME: "Clean Water & Climate Resilience Fund",

  // Estimated Aave V3 Supply APY
  ESTIMATED_APY: 5.25,

  // YieldEndowment Contract ABI
  ENDOWMENT_ABI: [
    "function deposit(uint256 amount) external",
    "function withdrawPrincipal(uint256 amount) external",
    "function harvestYield() external returns (uint256 yieldAmount)",
    "function harvestYieldAmount(uint256 amount) external returns (uint256 harvested)",
    "function getAccruedYield() external view returns (uint256)",
    "function getDonorPrincipal(address donor) external view returns (uint256)",
    "function getTotalValueLocked() external view returns (uint256)",
    "function totalPrincipal() external view returns (uint256)",
    "function totalYieldHarvested() external view returns (uint256)",
    "function donorCount() external view returns (uint256)",
    "function beneficiary() external view returns (address)",
    "function owner() external view returns (address)",
    "function setBeneficiary(address newBeneficiary) external",
    "event Deposited(address indexed donor, uint256 amount, uint256 newTotalUserPrincipal)",
    "event PrincipalWithdrawn(address indexed donor, uint256 amount, uint256 remainingUserPrincipal)",
    "event YieldHarvested(address indexed beneficiary, uint256 yieldAmount)",
    "event BeneficiaryUpdated(address indexed oldBeneficiary, address indexed newBeneficiary)"
  ],

  // Minimal ERC20 ABI
  ERC20_ABI: [
    "function balanceOf(address account) external view returns (uint256)",
    "function allowance(address owner, address spender) external view returns (uint256)",
    "function approve(address spender, uint256 amount) external returns (bool)",
    "function decimals() external view returns (uint8)",
    "event Approval(address indexed owner, address indexed spender, uint256 value)"
  ]
};


// Explicit network resolver (returns null for unspecified / unknown networks, no silent defaulting!)
window.getActiveNetwork = function(chainId) {
  // 1. Check URL parameter (?network=anvil vs ?network=sepolia)
  if (typeof window !== 'undefined' && window.location && window.location.search) {
    const urlParams = new URLSearchParams(window.location.search);
    const netParam = (urlParams.get('network') || '').toLowerCase();
    if (netParam === 'anvil' || netParam === 'local' || netParam === '31337') {
      return window.APP_CONFIG.NETWORKS["0x7a69"];
    }
    if (netParam === 'sepolia' || netParam === 'base' || netParam === '84532') {
      return window.APP_CONFIG.NETWORKS["0x14a34"];
    }
  }

  // 2. Check Chain ID provided by connected wallet
  if (chainId) {
    const cid = chainId.toString().toLowerCase();
    if (cid === '0x14a34' || cid === '84532') {
      return window.APP_CONFIG.NETWORKS["0x14a34"];
    }
    if (cid === '0x7a69' || cid === '31337' || cid === '0x539' || cid === '1337') {
      return window.APP_CONFIG.NETWORKS["0x7a69"];
    }
  }

  // 3. Return null if network is unspecified or unrecognized
  return null;
};
