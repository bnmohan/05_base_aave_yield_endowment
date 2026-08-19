// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/IPool.sol";

/// @title Aave Yield Savings Endowment Gateway
/// @notice Pools user stablecoin deposits into Aave V3 lending pool to generate yield for public campaigns.
/// @dev Separates donor principal from interest yield, enabling 100% principal protection while continuous yield supports campaigns.
contract YieldEndowment {
    // --- Custom Errors ---
    error ZeroAmount();
    error ZeroAddress();
    error InsufficientPrincipal(uint256 requested, uint256 available);
    error InsufficientYield(uint256 requested, uint256 available);
    error NoYieldToHarvest();
    error Unauthorized();
    error ContractPaused();

    // --- State Variables ---
    address public owner;
    address public beneficiary;
    bool public paused;

    IPool public immutable aavePool;
    IERC20 public immutable underlyingAsset;
    IERC20 public immutable aToken;

    uint256 public totalPrincipal;
    uint256 public totalYieldHarvested;
    uint256 public donorCount;

    mapping(address => uint256) public userPrincipals;
    mapping(address => bool) public hasDeposited;

    // --- Reentrancy Guard Variable ---
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    // --- Events ---
    event Deposited(address indexed donor, uint256 amount, uint256 newTotalUserPrincipal);
    event PrincipalWithdrawn(address indexed donor, uint256 amount, uint256 remainingUserPrincipal);
    event YieldHarvested(address indexed beneficiary, uint256 yieldAmount);
    event BeneficiaryUpdated(address indexed oldBeneficiary, address indexed newBeneficiary);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event PauseToggled(bool isPaused);

    // --- Modifiers ---
    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    modifier whenNotPaused() {
        if (paused) revert ContractPaused();
        _;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    /**
     * @notice Constructor initializing Aave Pool, asset, aToken, and campaign beneficiary.
     * @param _aavePool Address of the Aave V3 Pool contract.
     * @param _underlyingAsset Address of the underlying ERC20 stablecoin (e.g., USDC).
     * @param _aToken Address of the corresponding Aave interest-bearing aToken.
     * @param _beneficiary Address of the public campaign beneficiary receiving yield.
     */
    constructor(
        address _aavePool,
        address _underlyingAsset,
        address _aToken,
        address _beneficiary
    ) {
        if (_aavePool == address(0) || _underlyingAsset == address(0) || _aToken == address(0) || _beneficiary == address(0)) {
            revert ZeroAddress();
        }

        owner = msg.sender;
        aavePool = IPool(_aavePool);
        underlyingAsset = IERC20(_underlyingAsset);
        aToken = IERC20(_aToken);
        beneficiary = _beneficiary;

        _status = _NOT_ENTERED;
    }

    // --- Core Functions ---

    /**
     * @notice Deposit stablecoins into the endowment gateway.
     * @dev Transfers tokens from donor to this contract, approves Aave Pool, and supplies tokens to Aave V3.
     * @param amount Amount of underlying stablecoins to deposit.
     */
    function deposit(uint256 amount) external whenNotPaused nonReentrant {
        if (amount == 0) revert ZeroAmount();

        // Track donor count
        if (!hasDeposited[msg.sender]) {
            hasDeposited[msg.sender] = true;
            donorCount++;
        }

        // Transfer stablecoin from donor to this contract
        bool success = underlyingAsset.transferFrom(msg.sender, address(this), amount);
        require(success, "Deposit: Token transfer failed");

        // Approve Aave Pool to pull stablecoins
        underlyingAsset.approve(address(aavePool), amount);

        // Supply to Aave V3 Pool on behalf of this contract
        aavePool.supply(address(underlyingAsset), amount, address(this), 0);

        // Update principal accounting
        userPrincipals[msg.sender] += amount;
        totalPrincipal += amount;

        emit Deposited(msg.sender, amount, userPrincipals[msg.sender]);
    }

    /**
     * @notice Withdraw principal capital up to the caller's deposited amount.
     * @dev Redeems aTokens from Aave pool and returns underlying stablecoin to donor.
     * @param amount Amount of principal to withdraw.
     */
    function withdrawPrincipal(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();
        uint256 currentPrincipal = userPrincipals[msg.sender];
        if (amount > currentPrincipal) {
            revert InsufficientPrincipal(amount, currentPrincipal);
        }

        // Update accounting before external calls
        userPrincipals[msg.sender] = currentPrincipal - amount;
        totalPrincipal -= amount;

        // Withdraw underlying stablecoins from Aave pool directly to donor
        aavePool.withdraw(address(underlyingAsset), amount, msg.sender);

        emit PrincipalWithdrawn(msg.sender, amount, userPrincipals[msg.sender]);
    }

    /**
     * @notice Harvest all 100% of accrued lending interest yield to campaign beneficiary.
     * @return yieldAmount Amount of yield harvested and routed to beneficiary.
     */
    function harvestYield() external nonReentrant returns (uint256 yieldAmount) {
        yieldAmount = getAccruedYield();
        if (yieldAmount == 0) revert NoYieldToHarvest();

        totalYieldHarvested += yieldAmount;

        // Redeem accrued yield from Aave pool and send directly to beneficiary
        aavePool.withdraw(address(underlyingAsset), yieldAmount, beneficiary);

        emit YieldHarvested(beneficiary, yieldAmount);
    }

    /**
     * @notice Harvest a specific custom amount of accrued lending interest yield.
     * @param amount Specific amount of accrued yield to harvest and route to beneficiary.
     * @return harvested Amount of yield harvested.
     */
    function harvestYieldAmount(uint256 amount) external nonReentrant returns (uint256 harvested) {
        if (amount == 0) revert ZeroAmount();
        uint256 availableYield = getAccruedYield();
        if (availableYield == 0 || amount > availableYield) {
            revert InsufficientYield(amount, availableYield);
        }

        harvested = amount;
        totalYieldHarvested += harvested;

        // Redeem specified yield amount from Aave pool and send directly to beneficiary
        aavePool.withdraw(address(underlyingAsset), harvested, beneficiary);

        emit YieldHarvested(beneficiary, harvested);
    }

    // --- View Functions ---

    /**
     * @notice Calculates current accrued lending interest yield.
     * @return Accrued yield in underlying asset units (aToken balance minus total principal).
     */
    function getAccruedYield() public view returns (uint256) {
        uint256 aTokenBalance = aToken.balanceOf(address(this));
        if (aTokenBalance > totalPrincipal) {
            return aTokenBalance - totalPrincipal;
        }
        return 0;
    }

    /**
     * @notice Get principal balance for a specific donor.
     */
    function getDonorPrincipal(address donor) external view returns (uint256) {
        return userPrincipals[donor];
    }

    /**
     * @notice Get total value locked (aToken balance) in Aave pool.
     */
    function getTotalValueLocked() external view returns (uint256) {
        return aToken.balanceOf(address(this));
    }

    // --- Admin Functions ---

    /**
     * @notice Update campaign beneficiary address.
     */
    function setBeneficiary(address newBeneficiary) external onlyOwner {
        if (newBeneficiary == address(0)) revert ZeroAddress();
        emit BeneficiaryUpdated(beneficiary, newBeneficiary);
        beneficiary = newBeneficiary;
    }

    /**
     * @notice Toggle contract pause status.
     */
    function togglePause() external onlyOwner {
        paused = !paused;
        emit PauseToggled(paused);
    }

    /**
     * @notice Transfer ownership of the contract.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
