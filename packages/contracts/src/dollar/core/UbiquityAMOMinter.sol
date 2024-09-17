// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IUbiquityPool} from "../interfaces/IUbiquityPool.sol";

contract UbiquityAMOMinter is Ownable {
    using SafeERC20 for ERC20;

    // Core
    ERC20 public immutable collateral_token;
    IUbiquityPool public pool;

    // Collateral related
    address public immutable collateral_address;
    uint256 public immutable collateralIndex; // Index of the collateral in the pool
    uint256 public immutable missing_decimals;
    int256 public collat_borrow_cap = int256(100_000e18);

    // Collateral borrowed balances
    mapping(address => int256) public collat_borrowed_balances;
    int256 public collat_borrowed_sum = 0;

    // AMO management
    mapping(address => bool) public AMOs;

    /* ========== CONSTRUCTOR ========== */

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
        missing_decimals = uint(18) - collateral_token.decimals();

        emit OwnershipTransferred(_owner_address);
        emit PoolSet(_pool_address);
    }

    /* ========== MODIFIERS ========== */

    modifier validAMO(address amo_address) {
        require(AMOs[amo_address], "Invalid AMO");
        _;
    }

    /* ========== AMO MANAGEMENT FUNCTIONS ========== */

    function enableAMO(address amo) external onlyOwner {
        AMOs[amo] = true;
    }

    function disableAMO(address amo) external onlyOwner {
        AMOs[amo] = false;
    }

    /* ========== COLLATERAL FUNCTIONS ========== */

    function giveCollatToAMO(
        address destination_amo,
        uint256 collat_amount
    ) external onlyOwner validAMO(destination_amo) {
        // Check if the pool has enough collateral
        require(
            collateral_token.balanceOf(address(pool)) >= collat_amount,
            "Insufficient balance"
        );

        int256 collat_amount_i256 = int256(collat_amount);

        require(
            (collat_borrowed_sum + collat_amount_i256) <= collat_borrow_cap,
            "Borrow cap"
        );
        collat_borrowed_balances[destination_amo] += collat_amount_i256;
        collat_borrowed_sum += collat_amount_i256;

        // Borrow the collateral
        pool.amoMinterBorrow(collat_amount);

        // Give the collateral to the AMO
        collateral_token.safeTransfer(destination_amo, collat_amount);

        emit CollateralGivenToAMO(destination_amo, collat_amount);
    }

    function receiveCollatFromAMO(
        uint256 collat_amount
    ) external validAMO(msg.sender) {
        int256 collat_amt_i256 = int256(collat_amount);

        // First, update the balances
        collat_borrowed_balances[msg.sender] -= collat_amt_i256;
        collat_borrowed_sum -= collat_amt_i256;

        // Then perform transfer from
        collateral_token.safeTransferFrom(
            msg.sender,
            address(pool),
            collat_amount
        );

        emit CollateralReceivedFromAMO(msg.sender, collat_amount);
    }

    /* ========== RESTRICTED GOVERNANCE FUNCTIONS ========== */

    function setCollatBorrowCap(uint256 _collat_borrow_cap) external onlyOwner {
        collat_borrow_cap = int256(_collat_borrow_cap);
        emit CollatBorrowCapSet(_collat_borrow_cap);
    }

    function setPool(address _pool_address) external onlyOwner {
        pool = IUbiquityPool(_pool_address);
        emit PoolSet(_pool_address);
    }

    /* =========== VIEWS ========== */

    // Adheres to AMO minter pattern established in LibUbiquityPool
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
