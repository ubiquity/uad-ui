// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IUbiquityPool} from "../interfaces/IUbiquityPool.sol";

/**
 * @title UbiquityAmoMinter
 * @notice Contract responsible for managing collateral borrowing from Ubiquity's Pool to AMOs.
 * @notice Allows owner to move Dollar collateral to AMOs, enabling yield generation.
 * @notice It keeps track of borrowed collateral balances per Amo and the total borrowed sum.
 */
contract UbiquityAmoMinter is Ownable {
    using SafeERC20 for ERC20;

    /// @notice Collateral token used by the AMO minter
    ERC20 public immutable collateralToken;

    /// @notice Ubiquity pool interface
    IUbiquityPool public pool;

    /// @notice Collateral-related properties
    address public immutable collateralAddress;
    uint256 public immutable collateralIndex; // Index of the collateral in the pool
    uint256 public immutable missingDecimals;
    int256 public collateralBorrowCap = int256(100_000e18);

    /// @notice Mapping for tracking borrowed collateral balances per AMO
    mapping(address => int256) public collateralBorrowedBalances;

    /// @notice Sum of all collateral borrowed across Amos
    int256 public collateralTotalBorrowedBalance = 0;

    /// @notice Mapping to track active AMOs
    mapping(address => bool) public Amos;

    /* ========== CONSTRUCTOR ========== */

    /**
     * @notice Initializes the Amo minter contract
     * @param _ownerAddress Address of the contract owner
     * @param _collateralAddress Address of the collateral token
     * @param _collateralIndex Index of the collateral in the pool
     * @param _poolAddress Address of the Ubiquity pool
     */
    constructor(
        address _ownerAddress,
        address _collateralAddress,
        uint256 _collateralIndex,
        address _poolAddress
    ) {
        require(_ownerAddress != address(0), "Owner address cannot be zero");
        require(_poolAddress != address(0), "Pool address cannot be zero");

        // Set the owner
        transferOwnership(_ownerAddress);

        // Pool related
        pool = IUbiquityPool(_poolAddress);

        // Collateral related
        collateralAddress = _collateralAddress;
        collateralIndex = _collateralIndex;
        collateralToken = ERC20(_collateralAddress);
        missingDecimals = uint256(18) - collateralToken.decimals();

        emit OwnershipTransferred(_ownerAddress);
        emit PoolSet(_poolAddress);
    }

    /* ========== MODIFIERS ========== */

    /**
     * @notice Ensures the caller is a valid AMO
     * @param amoAddress Address of the AMO to check
     */
    modifier validAmo(address amoAddress) {
        require(Amos[amoAddress], "Invalid Amo");
        _;
    }

    /* ========== AMO MANAGEMENT FUNCTIONS ========== */

    /**
     * @notice Enables an AMO
     * @param amo Address of the AMO to enable
     */
    function enableAmo(address amo) external onlyOwner {
        Amos[amo] = true;
    }

    /**
     * @notice Disables an AMO
     * @param amo Address of the AMO to disable
     */
    function disableAmo(address amo) external onlyOwner {
        Amos[amo] = false;
    }

    /* ========== COLLATERAL FUNCTIONS ========== */

    /**
     * @notice Transfers collateral to the specified AMO
     * @param destinationAmo Address of the AMO to receive collateral
     * @param collateralAmount Amount of collateral to transfer
     */
    function giveCollateralToAmo(
        address destinationAmo,
        uint256 collateralAmount
    ) external onlyOwner validAmo(destinationAmo) {
        require(
            collateralToken.balanceOf(address(pool)) >= collateralAmount,
            "Insufficient balance"
        );

        int256 collateralAmount_i256 = int256(collateralAmount);

        require(
            (collateralTotalBorrowedBalance + collateralAmount_i256) <=
                collateralBorrowCap,
            "Borrow cap exceeded"
        );

        collateralBorrowedBalances[destinationAmo] += collateralAmount_i256;
        collateralTotalBorrowedBalance += collateralAmount_i256;

        // Borrow collateral from the pool
        pool.amoMinterBorrow(collateralAmount);

        // Transfer collateral to the AMO
        collateralToken.safeTransfer(destinationAmo, collateralAmount);

        emit CollateralGivenToAmo(destinationAmo, collateralAmount);
    }

    /**
     * @notice Receives collateral back from an AMO
     * @param collateralAmount Amount of collateral being returned
     */
    function receiveCollateralFromAmo(
        uint256 collateralAmount
    ) external validAmo(msg.sender) {
        int256 collateralAmount_i256 = int256(collateralAmount);

        // Update the collateral balances
        collateralBorrowedBalances[msg.sender] -= collateralAmount_i256;
        collateralTotalBorrowedBalance -= collateralAmount_i256;

        // Transfer collateral back to the pool
        collateralToken.safeTransferFrom(
            msg.sender,
            address(pool),
            collateralAmount
        );

        emit CollateralReceivedFromAmo(msg.sender, collateralAmount);
    }

    /* ========== RESTRICTED GOVERNANCE FUNCTIONS ========== */

    /**
     * @notice Updates the collateral borrow cap
     * @param _collateralBorrowCap New collateral borrow cap
     */
    function setCollateralBorrowCap(
        uint256 _collateralBorrowCap
    ) external onlyOwner {
        collateralBorrowCap = int256(_collateralBorrowCap);
        emit CollateralBorrowCapSet(_collateralBorrowCap);
    }

    /**
     * @notice Updates the pool address
     * @param _poolAddress New pool address
     */
    function setPool(address _poolAddress) external onlyOwner {
        pool = IUbiquityPool(_poolAddress);
        emit PoolSet(_poolAddress);
    }

    /* =========== VIEWS ========== */

    /**
     * @notice Returns the total value of borrowed collateral
     * @return Total balance of collateral borrowed
     */
    function collateralDollarBalance() external view returns (uint256) {
        return uint256(collateralTotalBorrowedBalance);
    }

    /* ========== EVENTS ========== */

    event CollateralGivenToAmo(
        address destinationAmo,
        uint256 collateralAmount
    );
    event CollateralReceivedFromAmo(
        address sourceAmo,
        uint256 collateralAmount
    );
    event CollateralBorrowCapSet(uint256 newCollateralBorrowCap);
    event PoolSet(address newPoolAddress);
    event OwnershipTransferred(address newOwner);
}
