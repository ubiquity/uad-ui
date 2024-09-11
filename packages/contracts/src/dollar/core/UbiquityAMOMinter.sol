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

    address public timelock_address;

    // Collateral related
    address public immutable collateral_address;
    uint256 public immutable missing_decimals;
    int256 public collat_borrow_cap = int256(10000000e6);

    // Collateral borrowed balances
    mapping(address => int256) public collat_borrowed_balances;
    int256 public collat_borrowed_sum = 0;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _owner_address,
        address _timelock_address,
        address _collateral_address,
        address _pool_address
    ) {
        require(_owner_address != address(0), "Owner address cannot be zero");
        require(
            _timelock_address != address(0),
            "Timelock address cannot be zero"
        );
        require(_pool_address != address(0), "Pool address cannot be zero");

        // Set the owner
        transferOwnership(_owner_address);

        timelock_address = _timelock_address;

        // Pool related
        pool = IUbiquityPool(_pool_address);

        // Collateral related
        collateral_address = _collateral_address;
        collateral_token = ERC20(_collateral_address);
        missing_decimals = uint(18) - collateral_token.decimals();

        emit OwnershipTransferred(_owner_address);
        emit TimelockSet(_timelock_address);
        emit PoolSet(_pool_address);
    }

    /* ========== MODIFIERS ========== */

    modifier onlyByOwnGov() {
        require(
            msg.sender == timelock_address || msg.sender == owner(),
            "Not owner or timelock"
        );
        _;
    }

    modifier validAMO(address amo_address) {
        require(collat_borrowed_balances[amo_address] >= 0, "Invalid AMO");
        _;
    }

    /* ========== COLLATERAL FUNCTIONS ========== */

    function giveCollatToAMO(
        address destination_amo,
        uint256 collat_amount
    ) external onlyByOwnGov validAMO(destination_amo) {
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

    function setCollatBorrowCap(
        uint256 _collat_borrow_cap
    ) external onlyByOwnGov {
        collat_borrow_cap = int256(_collat_borrow_cap);
        emit CollatBorrowCapSet(_collat_borrow_cap);
    }

    function setTimelock(address new_timelock) external onlyByOwnGov {
        require(new_timelock != address(0), "Timelock address cannot be 0");
        timelock_address = new_timelock;
        emit TimelockSet(new_timelock);
    }

    function setPool(address _pool_address) external onlyByOwnGov {
        pool = IUbiquityPool(_pool_address);
        emit PoolSet(_pool_address);
    }

    /* ========== EVENTS ========== */

    event CollateralGivenToAMO(address destination_amo, uint256 collat_amount);
    event CollateralReceivedFromAMO(address source_amo, uint256 collat_amount);
    event CollatBorrowCapSet(uint256 new_collat_borrow_cap);
    event TimelockSet(address new_timelock);
    event PoolSet(address new_pool_address);
    event OwnershipTransferred(address new_owner);
}
