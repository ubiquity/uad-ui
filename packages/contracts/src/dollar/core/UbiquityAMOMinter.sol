// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IUbiquityPool} from "../interfaces/IUbiquityPool.sol";

/**
 * @title UbiquityAMOMinter
 * @notice Contract responsible for managing collateral borrowing from Ubiquity's Pool for AMO.
 * @notice Allows owner to move Dollar collateral to AMOs, enabling yield generation.
 * @notice It keeps track of borrowed collateral balances per AMO and the total borrowed sum.
 */
contract UbiquityAMOMinter is Ownable {
    using SafeERC20 for ERC20;

    /// @notice Collateral token used by the AMO minter
    ERC20 public immutable collateral_token;

    /// @notice Ubiquity pool interface
    IUbiquityPool public pool;

    /// @notice Collateral-related properties
    address public immutable collateral_address;
    uint256 public immutable collateralIndex; // Index of the collateral in the pool
    uint256 public immutable missing_decimals;
    int256 public collat_borrow_cap = int256(100_000e18);

    /// @notice Mapping for tracking borrowed collateral balances per AMO
    mapping(address => int256) public collat_borrowed_balances;

    /// @notice Sum of all collateral borrowed across AMOs
    int256 public collat_borrowed_sum = 0;

    /// @notice Mapping to track active AMOs
    mapping(address => bool) public AMOs;

    /* ========== CONSTRUCTOR ========== */

    /**
     * @notice Initializes the AMO minter contract
     * @param _owner_address Address of the contract owner
     * @param _collateral_address Address of the collateral token
     * @param _collateralIndex Index of the collateral in the pool
     * @param _pool_address Address of the Ubiquity pool
     */
    constructor(
        address _owner_address,
        address _collateral_address,
        uint256 _collateralIndex,
        address _pool_address
    ) {
        require(_owner_address != address(0), "Owner address cannot be zero");
        require(_pool_address != address(0), "Pool address cannot be zero");

        // Set the owner
        transferOwnership(_owner_address);

        // Pool related
        pool = IUbiquityPool(_pool_address);

        // Collateral related
        collateral_address = _collateral_address;
        collateralIndex = _collateralIndex;
        collateral_token = ERC20(_collateral_address);
        missing_decimals = uint256(18) - collateral_token.decimals();

        emit OwnershipTransferred(_owner_address);
        emit PoolSet(_pool_address);
    }

    /* ========== MODIFIERS ========== */

    /**
     * @notice Ensures the caller is a valid AMO
     * @param amo_address Address of the AMO to check
     */
    modifier validAMO(address amo_address) {
        require(AMOs[amo_address], "Invalid AMO");
        _;
    }

    /* ========== AMO MANAGEMENT FUNCTIONS ========== */

    /**
     * @notice Enables an AMO
     * @param amo Address of the AMO to enable
     */
    function enableAMO(address amo) external onlyOwner {
        AMOs[amo] = true;
    }

    /**
     * @notice Disables an AMO
     * @param amo Address of the AMO to disable
     */
    function disableAMO(address amo) external onlyOwner {
        AMOs[amo] = false;
    }

    /* ========== COLLATERAL FUNCTIONS ========== */

    /**
     * @notice Transfers collateral to the specified AMO
     * @param destination_amo Address of the AMO to receive collateral
     * @param collat_amount Amount of collateral to transfer
     */
    function giveCollatToAMO(
        address destination_amo,
        uint256 collat_amount
    ) external onlyOwner validAMO(destination_amo) {
        require(
            collateral_token.balanceOf(address(pool)) >= collat_amount,
            "Insufficient balance"
        );

        int256 collat_amount_i256 = int256(collat_amount);

        require(
            (collat_borrowed_sum + collat_amount_i256) <= collat_borrow_cap,
            "Borrow cap exceeded"
        );

        collat_borrowed_balances[destination_amo] += collat_amount_i256;
        collat_borrowed_sum += collat_amount_i256;

        // Borrow collateral from the pool
        pool.amoMinterBorrow(collat_amount);

        // Transfer collateral to the AMO
        collateral_token.safeTransfer(destination_amo, collat_amount);

        emit CollateralGivenToAMO(destination_amo, collat_amount);
    }

    /**
     * @notice Receives collateral back from an AMO
     * @param collat_amount Amount of collateral being returned
     */
    function receiveCollatFromAMO(
        uint256 collat_amount
    ) external validAMO(msg.sender) {
        int256 collat_amt_i256 = int256(collat_amount);

        // Update the collateral balances
        collat_borrowed_balances[msg.sender] -= collat_amt_i256;
        collat_borrowed_sum -= collat_amt_i256;

        // Transfer collateral back to the pool
        collateral_token.safeTransferFrom(
            msg.sender,
            address(pool),
            collat_amount
        );

        emit CollateralReceivedFromAMO(msg.sender, collat_amount);
    }

    /* ========== RESTRICTED GOVERNANCE FUNCTIONS ========== */

    /**
     * @notice Updates the collateral borrow cap
     * @param _collat_borrow_cap New collateral borrow cap
     */
    function setCollatBorrowCap(uint256 _collat_borrow_cap) external onlyOwner {
        collat_borrow_cap = int256(_collat_borrow_cap);
        emit CollatBorrowCapSet(_collat_borrow_cap);
    }

    /**
     * @notice Updates the pool address
     * @param _pool_address New pool address
     */
    function setPool(address _pool_address) external onlyOwner {
        pool = IUbiquityPool(_pool_address);
        emit PoolSet(_pool_address);
    }

    /* =========== VIEWS ========== */

    /**
     * @notice Returns the total value of borrowed collateral
     * @return Total balance of collateral borrowed
     */
    function collateralDollarBalance() external view returns (uint256) {
        return uint256(collat_borrowed_sum);
    }

    /* ========== EVENTS ========== */

    event CollateralGivenToAMO(address destination_amo, uint256 collat_amount);
    event CollateralReceivedFromAMO(address source_amo, uint256 collat_amount);
    event CollatBorrowCapSet(uint256 new_collat_borrow_cap);
    event PoolSet(address new_pool_address);
    event OwnershipTransferred(address new_owner);
}
