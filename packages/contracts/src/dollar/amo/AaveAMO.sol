// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;

import {UbiquityAMOMinter} from "../core/UbiquityAMOMinter.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {TransferHelper} from "../libraries/TransferHelper.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IAAVELendingPool_Partial} from "../interfaces/aave/IAAVELendingPool_Partial.sol";
import {IStakedAave} from "../interfaces/aave/IStakedAave.sol";
import {IAaveIncentivesControllerPartial} from "../interfaces/aave/IAaveIncentivesControllerPartial.sol";
import {IProtocolDataProvider} from "../interfaces/aave/IProtocolDataProvider.sol";

contract AaveAMO is Ownable {
    /* ========== STATE VARIABLES ========== */
    address public timelock_address;
    address public custodian_address;

    // Constants
    UbiquityAMOMinter private amo_minter;

    // Pools and vaults
    IAAVELendingPool_Partial private constant aaveLending_Pool =
        IAAVELendingPool_Partial(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);

    // Reward Tokens
    ERC20 private constant AAVE =
        ERC20(0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9);
    IStakedAave private constant stkAAVE =
        IStakedAave(0x4da27a545c0c5B758a6BA100e3a049001de870f5);
    IAaveIncentivesControllerPartial private constant AAVEIncentivesController =
        IAaveIncentivesControllerPartial(
            0xd784927Ff2f95ba542BfC824c8a8a98F3495f6b5
        );
    IProtocolDataProvider private constant AAVEProtocolDataProvider =
        IProtocolDataProvider(0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d);

    // Borrowed assets
    address[] public aave_borrow_asset_list;
    mapping(address => bool) public aave_borrow_asset_check; // Mapping is also used for faster verification

    // Settings
    uint256 private constant PRICE_PRECISION = 1e6;

    /* ========== CONSTRUCTOR ========== */

    constructor(address _owner_address, address _amo_minter_address) {
        // Set owner
        transferOwnership(_owner_address);

        amo_minter = UbiquityAMOMinter(_amo_minter_address);

        // Get the custodian and timelock addresses from the minter
        custodian_address = amo_minter.custodian_address();
        timelock_address = amo_minter.timelock_address();
    }

    /* ========== MODIFIERS ========== */

    modifier onlyByOwnGov() {
        require(
            msg.sender == timelock_address || msg.sender == owner(),
            "Not owner or timelock"
        );
        _;
    }

    modifier onlyByOwnGovCust() {
        require(
            msg.sender == timelock_address ||
                msg.sender == owner() ||
                msg.sender == custodian_address,
            "Not owner, timelock, or custodian"
        );
        _;
    }

    modifier onlyByMinter() {
        require(msg.sender == address(amo_minter), "Not minter");
        _;
    }

    /* ========== VIEWS ========== */

    function showDebtsByAsset(
        address asset_address
    ) public view returns (uint256[3] memory debts) {
        require(
            aave_borrow_asset_check[asset_address],
            "Asset is not available in borrowed list."
        );
        (
            ,
            uint256 currentStableDebt,
            uint256 currentVariableDebt,
            ,
            ,
            ,
            ,
            ,

        ) = AAVEProtocolDataProvider.getUserReserveData(
                asset_address,
                address(this)
            );
        debts[0] = currentStableDebt + currentVariableDebt; // Total debt balance
        ERC20 _asset = ERC20(asset_address);
        debts[1] = _asset.balanceOf(address(this)); // AMO Asset balance
        debts[2] = 0; // Removed aaveToken reference (not applicable without aToken)
    }

    /// @notice For potential Aave incentives in the future
    /// @return rewards :
    /// rewards[0] = stkAAVE balance
    /// rewards[1] = AAVE balance
    function showRewards() external view returns (uint256[2] memory rewards) {
        rewards[0] = stkAAVE.balanceOf(address(this)); // stkAAVE
        rewards[1] = AAVE.balanceOf(address(this)); // AAVE
    }

    /* ========== AAVE V2 + stkAAVE ========== */

    /// @notice Function to deposit other assets as collateral to Aave pool
    /// @param collateral_address collateral ERC20 address
    /// @param amount Amount of asset to be deposited
    function aaveDepositCollateral(
        address collateral_address,
        uint256 amount
    ) public onlyByOwnGovCust {
        ERC20 token = ERC20(collateral_address);
        token.approve(address(aaveLending_Pool), amount);
        aaveLending_Pool.deposit(collateral_address, amount, address(this), 0);
    }

    /// @notice Function to withdraw other assets as collateral from Aave pool
    /// @param collateral_address collateral ERC20 address
    /// @param aToken_amount Amount of asset to be withdrawn
    function aaveWithdrawCollateral(
        address collateral_address,
        uint256 aToken_amount
    ) public onlyByOwnGovCust {
        aaveLending_Pool.withdraw(
            collateral_address,
            aToken_amount,
            address(this)
        );
    }

    /// @notice Function to borrow other assets from Aave pool
    /// @param asset Borrowing asset ERC20 address
    /// @param borrow_amount Amount of asset to be borrowed
    /// @param interestRateMode The interest rate mode: 1 for Stable, 2 for Variable
    function aaveBorrow(
        address asset,
        uint256 borrow_amount,
        uint256 interestRateMode
    ) public onlyByOwnGovCust {
        aaveLending_Pool.borrow(
            asset,
            borrow_amount,
            interestRateMode,
            0,
            address(this)
        );
        aave_borrow_asset_check[asset] = true;
        aave_borrow_asset_list.push(asset);
    }

    /// @notice Function to repay other assets to Aave pool
    /// @param asset Borrowing asset ERC20 address
    /// @param repay_amount Amount of asset to be repaid
    /// @param interestRateMode The interest rate mode: 1 for Stable, 2 for Variable
    function aaveRepay(
        address asset,
        uint256 repay_amount,
        uint256 interestRateMode
    ) public onlyByOwnGovCust {
        ERC20 token = ERC20(asset);
        token.approve(address(aaveLending_Pool), repay_amount);
        aaveLending_Pool.repay(
            asset,
            repay_amount,
            interestRateMode,
            address(this)
        );
    }

    /// @notice Function to Collect stkAAVE
    /// @param withdraw_too true for withdraw rewards, false for keeping rewards in AMO
    function aaveCollect_stkAAVE(bool withdraw_too) public onlyByOwnGovCust {
        address[] memory the_assets = new address[](1);
        uint256 rewards_balance = AAVEIncentivesController.getRewardsBalance(
            the_assets,
            address(this)
        );
        AAVEIncentivesController.claimRewards(
            the_assets,
            rewards_balance,
            address(this)
        );

        if (withdraw_too) {
            withdrawRewards();
        }
    }

    /* ========== Rewards ========== */

    /// @notice Withdraw rewards in AAVE and stkAAVE
    function withdrawRewards() public onlyByOwnGovCust {
        bool result;
        result = stkAAVE.transfer(msg.sender, stkAAVE.balanceOf(address(this)));
        require(result, "stkAAVE transfer failed");
        result = AAVE.transfer(msg.sender, AAVE.balanceOf(address(this)));
        require(result, "AAVE transfer failed");
    }

    /* ========== RESTRICTED GOVERNANCE FUNCTIONS ========== */

    function setAMOMinter(address _amo_minter_address) external onlyByOwnGov {
        amo_minter = UbiquityAMOMinter(_amo_minter_address);

        custodian_address = amo_minter.custodian_address();
        timelock_address = amo_minter.timelock_address();

        require(
            custodian_address != address(0) && timelock_address != address(0),
            "Invalid custodian or timelock"
        );
    }

    // Emergency ERC20 recovery function
    function recoverERC20(
        address tokenAddress,
        uint256 tokenAmount
    ) external onlyByOwnGov {
        TransferHelper.safeTransfer(
            address(tokenAddress),
            msg.sender,
            tokenAmount
        );
    }

    // Emergency generic proxy - allows owner to execute arbitrary calls on this contract
    function execute(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyByOwnGov returns (bool, bytes memory) {
        (bool success, bytes memory result) = _to.call{value: _value}(_data);
        return (success, result);
    }
}
