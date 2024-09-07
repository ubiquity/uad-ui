// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {IUbiquityDollarToken} from "../interfaces/IUbiquityDollarToken.sol"; 
import {IUbiquityGovernanceToken} from "../interfaces/IUbiquityGovernance.sol";
import {IUbiquityPool} from "../interfaces/IUbiquityPool.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IAMO} from "../interfaces/IAMO.sol";
import {TransferHelper} from "../libraries/TransferHelper.sol";
import {LibUbiquityPool} from "../libraries/LibUbiquityPool.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract UbiquityAMOMinter is Ownable {
    // SafeMath automatically included in Solidity >= 8.0.0

    /* ========== STATE VARIABLES ========== */

    // Core
    IUbiquityDollarToken public uAD = IUbiquityDollarToken(0x0F644658510c95CB46955e55D7BA9DDa9E9fBEc6);
    IUbiquityGovernanceToken public UBQ = IUbiquityGovernanceToken(0x4e38D89362f7e5db0096CE44ebD021c3962aA9a0);
    ERC20 public collateral_token;
    IUbiquityPool public pool = IUbiquityPool(0xED3084c98148e2528DaDCB53C56352e549C488fA);

    address public timelock_address;
    address public custodian_address;   

    // Collateral related
    address public collateral_address;
    uint256 public col_idx;

    // AMO addresses
    address[] public amos_array;
    mapping(address => bool) public amos; // Mapping is also used for faster verification

    // Price constants
    uint256 private constant PRICE_PRECISION = 1e6;

    // Max amount of collateral the contract can borrow from the Ubiquity Pool
    int256 public collat_borrow_cap = int256(10000000e6);

    // Max amount of uAD and UBQ this contract can mint
    int256 public uad_mint_cap = int256(100000000e18);
    int256 public ubq_mint_cap = int256(100000000e18);

    // Minimum collateral ratio needed for new uAD minting
    uint256 public min_cr = 810000;

    // uAD mint balances
    mapping(address => int256) public uad_mint_balances; // Amount of uAD the contract minted, by AMO
    int256 public uad_mint_sum = 0; // Across all AMOs

    // UBQ mint balances
    mapping(address => int256) public ubq_mint_balances; // Amount of UBQ the contract minted, by AMO
    int256 public ubq_mint_sum = 0; // Across all AMOs

    // Collateral borrowed balances
    mapping(address => int256) public collat_borrowed_balances; // Amount of collateral the contract borrowed, by AMO
    int256 public collat_borrowed_sum = 0; // Across all AMOs

    // uAD balance related
    uint256 public ubiquityDollarBalanceStored = 0;

    // Collateral balance related
    uint256 public missing_decimals;
    uint256 public collatDollarBalanceStored = 0;

    // AMO balance corrections
    mapping(address => int256[2]) public correction_offsets_amos;
    // [amo_address][0] = AMO's uad_val_e18
    // [amo_address][1] = AMO's collat_val_e18

    /* ========== CONSTRUCTOR ========== */
    
    constructor (
        address _owner_address,
        address _custodian_address,
        address _timelock_address,
        address _collateral_address,
        address _pool_address
    ) {
        // Set the owner
        transferOwnership(_owner_address);

        custodian_address = _custodian_address;
        timelock_address = _timelock_address;

        // Pool related
        pool = IUbiquityPool(_pool_address);

        // Collateral related
        collateral_address = _collateral_address;
        col_idx = pool.collateralInformation(collateral_address).index;
        collateral_token = ERC20(_collateral_address);
        missing_decimals = uint(18) - collateral_token.decimals();
    }

    /* ========== MODIFIERS ========== */

    modifier onlyByOwnGov() {
        require(msg.sender == timelock_address || msg.sender == owner(), "Not owner or timelock");
        _;
    }

    modifier validAMO(address amo_address) {
        require(amos[amo_address], "Invalid AMO");
        _;
    }

    /* ========== VIEWS ========== */

    function collatDollarBalance() external view returns (uint256) {
        (, uint256 collat_val_e18) = dollarBalances();
        return collat_val_e18;
    }

    function dollarBalances() public view returns (uint256 uad_val_e18, uint256 collat_val_e18) {
        uad_val_e18 = ubiquityDollarBalanceStored;
        collat_val_e18 = collatDollarBalanceStored;
    }

    function allAMOAddresses() external view returns (address[] memory) {
        return amos_array;
    }

    function allAMOsLength() external view returns (uint256) {
        return amos_array.length;
    }

    function uadTrackedGlobal() external view returns (int256) {
        return int256(ubiquityDollarBalanceStored) - uad_mint_sum - (collat_borrowed_sum * int256(10 ** missing_decimals));
    }

    function uadTrackedAMO(address amo_address) external view returns (int256) {
        (uint256 uad_val_e18, ) = IAMO(amo_address).dollarBalances();
        int256 uad_val_e18_corrected = int256(uad_val_e18) + correction_offsets_amos[amo_address][0];
        return uad_val_e18_corrected - uad_mint_balances[amo_address] - ((collat_borrowed_balances[amo_address]) * int256(10 ** missing_decimals));
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    // Callable by anyone willing to pay the gas
    function syncDollarBalances() public {
        uint256 total_uad_value_e18 = 0;
        uint256 total_collateral_value_e18 = 0; 
        for (uint i = 0; i < amos_array.length; i++){ 
            // Exclude null addresses
            address amo_address = amos_array[i];
            if (amo_address != address(0)){
                (uint256 uad_val_e18, uint256 collat_val_e18) = IAMO(amo_address).dollarBalances();
                total_uad_value_e18 += uint256(int256(uad_val_e18) + correction_offsets_amos[amo_address][0]);
                total_collateral_value_e18 += uint256(int256(collat_val_e18) + correction_offsets_amos[amo_address][1]);
            }
        }
        ubiquityDollarBalanceStored = total_uad_value_e18;
        collatDollarBalanceStored = total_collateral_value_e18;
    }

    /* ========== OWNER / GOVERNANCE FUNCTIONS ONLY ========== */
    // Only owner or timelock can call, to limit risk 

    // ------------------------------------------------------------------
    // ------------------------------- uAD ------------------------------
    // ------------------------------------------------------------------

    // This contract is essentially marked as a 'pool' so it can call OnlyPools functions like pool_mint and pool_burn_from
    // on the main uAD contract
    function mintUADForAMO(address destination_amo, uint256 uad_amount) external onlyByOwnGov validAMO(destination_amo) {
        int256 uad_amt_i256 = int256(uad_amount);

        // Make sure you aren't minting more than the mint cap
        require((uad_mint_sum + uad_amt_i256) <= uad_mint_cap, "Mint cap reached");
        uad_mint_balances[destination_amo] += uad_amt_i256;
        uad_mint_sum += uad_amt_i256;

        // Make sure the uAD minting wouldn't push the CR down too much
        // This is also a sanity check for the int256 math
        uint256 current_collateral_E18 = pool.collateralUsdBalance();
        uint256 cur_uad_supply = uAD.totalSupply();
        uint256 new_uad_supply = cur_uad_supply + uad_amount;
        uint256 new_cr = (current_collateral_E18 * PRICE_PRECISION) / new_uad_supply;
        require(new_cr >= min_cr, "CR would be too low");

        // Mint the uAD to the AMO
        // pool.mintDollar(col_idx, uad_amount, uad_amount, );

        // Sync
        syncDollarBalances();
    }

    function burnUADFromAMO(uint256 uad_amount) external validAMO(msg.sender) {
        int256 uad_amt_i256 = int256(uad_amount);

        // Burn first
        //uAD.pool_burn_from(msg.sender, uad_amount);

        // Then update the balances
        uad_mint_balances[msg.sender] -= uad_amt_i256;
        uad_mint_sum -= uad_amt_i256;

        // Sync
        syncDollarBalances();
    }

    // ------------------------------------------------------------------
    // ------------------------------- UBQ ------------------------------
    // ------------------------------------------------------------------

    function mintUBQForAMO(address destination_amo, uint256 ubq_amount) external onlyByOwnGov validAMO(destination_amo) {
        int256 ubq_amount_i256 = int256(ubq_amount);

        // Make sure you aren't minting more than the mint cap
        require((ubq_mint_sum + ubq_amount_i256) <= ubq_mint_cap, "Mint cap reached");
        ubq_mint_balances[destination_amo] += ubq_amount_i256;
        ubq_mint_sum += ubq_amount_i256;

        // Mint the UBQ to the AMO
        // UBQ.pool_mint(destination_amo, ubq_amount);

        // Sync
        syncDollarBalances();
    }

    function burnUBQFromAMO(uint256 ubq_amount) external validAMO(msg.sender) {
        int256 ubq_amount_i256 = int256(ubq_amount);

        // first
        // UBQ.pool_burn_from(msg.sender, ubq_amount);

        // Then update the balances
        ubq_mint_balances[msg.sender] -= ubq_amount_i256;
        ubq_mint_sum -= ubq_amount_i256;

        // Sync
        syncDollarBalances();
    }

    // ------------------------------------------------------------------
    // --------------------------- Collateral ---------------------------
    // ------------------------------------------------------------------

    function giveCollatToAMO(
        address destination_amo,
        uint256 collat_amount
    ) external onlyByOwnGov validAMO(destination_amo) {
        int256 collat_amount_i256 = int256(collat_amount);

        require((collat_borrowed_sum + collat_amount_i256) <= collat_borrow_cap, "Borrow cap");
        collat_borrowed_balances[destination_amo] += collat_amount_i256;
        collat_borrowed_sum += collat_amount_i256;

        // Borrow the collateral
        pool.amoMinterBorrow(collat_amount);

        // Give the collateral to the AMO
        TransferHelper.safeTransfer(collateral_address, destination_amo, collat_amount);

        // Sync
        syncDollarBalances();
    }

    function receiveCollatFromAMO(uint256 usdc_amount) external validAMO(msg.sender) {
        int256 collat_amt_i256 = int256(usdc_amount);

        // Give back first
        TransferHelper.safeTransferFrom(collateral_address, msg.sender, address(pool), usdc_amount);

        // Then update the balances
        collat_borrowed_balances[msg.sender] -= collat_amt_i256;
        collat_borrowed_sum -= collat_amt_i256;

        // Sync
        syncDollarBalances();
    }

    /* ========== RESTRICTED GOVERNANCE FUNCTIONS ========== */

    // Adds an AMO 
    function addAMO(address amo_address, bool sync_too) public onlyByOwnGov {
        require(amo_address != address(0), "Zero address detected");

        (uint256 uad_val_e18, uint256 collat_val_e18) = IAMO(amo_address).dollarBalances();
        require(uad_val_e18 >= 0 && collat_val_e18 >= 0, "Invalid AMO");

        require(amos[amo_address] == false, "Address already exists");
        amos[amo_address] = true; 
        amos_array.push(amo_address);

        // Mint balances
        uad_mint_balances[amo_address] = 0;
        ubq_mint_balances[amo_address] = 0;
        collat_borrowed_balances[amo_address] = 0;

        // Offsets
        correction_offsets_amos[amo_address][0] = 0;
        correction_offsets_amos[amo_address][1] = 0;

        if (sync_too) syncDollarBalances();

        emit AMOAdded(amo_address);
    }

    // Removes an AMO
    function removeAMO(address amo_address, bool sync_too) public onlyByOwnGov {
        require(amo_address != address(0), "Zero address detected");
        require(amos[amo_address] == true, "Address nonexistent");
        
        // Delete from the mapping
        delete amos[amo_address];

        // 'Delete' from the array by setting the address to 0x0
        for (uint i = 0; i < amos_array.length; i++){ 
            if (amos_array[i] == amo_address) {
                amos_array[i] = address(0); // This will leave a null in the array and keep the indices the same
                break;
            }
        }

        if (sync_too) syncDollarBalances();

        emit AMORemoved(amo_address);
    }

    function setTimelock(address new_timelock) external onlyByOwnGov {
        require(new_timelock != address(0), "Timelock address cannot be 0");
        timelock_address = new_timelock;
    }

    function setCustodian(address _custodian_address) external onlyByOwnGov {
        require(_custodian_address != address(0), "Custodian address cannot be 0");        
        custodian_address = _custodian_address;
    }

    function setUADMintCap(uint256 _uad_mint_cap) external onlyByOwnGov {
        uad_mint_cap = int256(_uad_mint_cap);
    }

    function setUBQMintCap(uint256 _ubq_mint_cap) external onlyByOwnGov {
        ubq_mint_cap = int256(_ubq_mint_cap);
    }

    function setCollatBorrowCap(uint256 _collat_borrow_cap) external onlyByOwnGov {
        collat_borrow_cap = int256(_collat_borrow_cap);
    }

    function setMinimumCollateralRatio(uint256 _min_cr) external onlyByOwnGov {
        min_cr = _min_cr;
    }

    function setAMOCorrectionOffsets(address amo_address, int256 uad_e18_correction, int256 collat_e18_correction) external onlyByOwnGov {
        correction_offsets_amos[amo_address][0] = uad_e18_correction;
        correction_offsets_amos[amo_address][1] = collat_e18_correction;

        syncDollarBalances();
    }

    function setUADPool(address _pool_address) external onlyByOwnGov {
        pool = IUbiquityPool(_pool_address);

        // Make sure the collaterals match, or balances could get corrupted
        require(pool.collateralInformation(collateral_address).index == col_idx, "col_idx mismatch");
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyByOwnGov {
        // Can only be triggered by owner or governance
        TransferHelper.safeTransfer(tokenAddress, owner(), tokenAmount);
        
        emit Recovered(tokenAddress, tokenAmount);
    }

    // Generic proxy
    function execute(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyByOwnGov returns (bool, bytes memory) {
        (bool success, bytes memory result) = _to.call{value:_value}(_data);
        return (success, result);
    }

    /* ========== EVENTS ========== */

    event AMOAdded(address amo_address);
    event AMORemoved(address amo_address);
    event Recovered(address token, uint256 amount);
}