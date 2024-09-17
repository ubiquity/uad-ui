// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {UbiquityAMOMinter} from "../core/UbiquityAMOMinter.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IPool} from "@aavev3-core/contracts/interfaces/IPool.sol";
import {IPoolDataProvider} from "@aavev3-core/contracts/interfaces/IPoolDataProvider.sol";
import {IRewardsController} from "@aavev3-periphery/contracts/rewards/interfaces/IRewardsController.sol";

contract AaveAMO is Ownable {
    using SafeERC20 for ERC20;

    /* ========== STATE VARIABLES ========== */

    // Constants
    UbiquityAMOMinter public amo_minter;

    // Pools and vaults
    IPool public immutable aave_pool;

    // Reward Tokens
    ERC20 public immutable AAVE;

    // Rewards Controller
    IRewardsController public immutable AAVERewardsController;

    // Aave data provider
    IPoolDataProvider public immutable AAVEPoolDataProvider;

    // Borrowed assets
    address[] public aave_borrow_asset_list;
    mapping(address => bool) public aave_borrow_asset_check; // Mapping is also used for faster verification

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _owner_address,
        address _amo_minter_address,
        address _aave_pool,
        address _aave,
        address _aave_rewards_controller,
        address _aave_pool_data_provider
    ) {
        require(_owner_address != address(0), "Owner address cannot be zero");
        require(
            _amo_minter_address != address(0),
            "AMO minter address cannot be zero"
        );
        require(_aave_pool != address(0), "Aave pool address cannot be zero");
        require(_aave != address(0), "AAVE address cannot be zero");
        require(
            _aave_rewards_controller != address(0),
            "AAVE rewards controller address cannot be zero"
        );
        require(
            _aave_pool_data_provider != address(0),
            "AAVE pool data provider address cannot be zero"
        );

        // Set owner
        transferOwnership(_owner_address);

        // Set AMO minter
        amo_minter = UbiquityAMOMinter(_amo_minter_address);

        // Set Aave pool
        aave_pool = IPool(_aave_pool);

        // Set AAVE
        AAVE = ERC20(_aave);

        // Set AAVE rewards controller
        AAVERewardsController = IRewardsController(_aave_rewards_controller);

        // Set AAVE pool data provider
        AAVEPoolDataProvider = IPoolDataProvider(_aave_pool_data_provider);
    }

    /* ========== MODIFIERS ========== */

    modifier onlyByMinter() {
        require(msg.sender == address(amo_minter), "Not minter");
        _;
    }

    /* ========== AAVE V3 + Rewards ========== */

    /// @notice Function to deposit other assets as collateral to Aave pool
    /// @param collateral_address collateral ERC20 address
    /// @param amount Amount of asset to be deposited
    function aaveDepositCollateral(
        address collateral_address,
        uint256 amount
    ) public onlyOwner {
        ERC20 token = ERC20(collateral_address);
        token.safeApprove(address(aave_pool), amount);
        aave_pool.deposit(collateral_address, amount, address(this), 0);

        emit CollateralDeposited(collateral_address, amount);
    }

    /// @notice Function to withdraw other assets as collateral from Aave pool
    /// @param collateral_address collateral ERC20 address
    /// @param aToken_amount Amount of asset to be withdrawn
    function aaveWithdrawCollateral(
        address collateral_address,
        uint256 aToken_amount
    ) public onlyOwner {
        aave_pool.withdraw(collateral_address, aToken_amount, address(this));

        emit CollateralWithdrawn(collateral_address, aToken_amount);
    }

    /// @notice Function to borrow other assets from Aave pool
    /// @param asset Borrowing asset ERC20 address
    /// @param borrow_amount Amount of asset to be borrowed
    /// @param interestRateMode The interest rate mode: 1 for Stable, 2 for Variable
    function aaveBorrow(
        address asset,
        uint256 borrow_amount,
        uint256 interestRateMode
    ) public onlyOwner {
        aave_pool.borrow(
            asset,
            borrow_amount,
            interestRateMode,
            0,
            address(this)
        );
        aave_borrow_asset_check[asset] = true;
        aave_borrow_asset_list.push(asset);

        emit Borrowed(asset, borrow_amount, interestRateMode);
    }

    /// @notice Function to repay other assets to Aave pool
    /// @param asset Borrowing asset ERC20 address
    /// @param repay_amount Amount of asset to be repaid
    /// @param interestRateMode The interest rate mode: 1 for Stable, 2 for Variable
    function aaveRepay(
        address asset,
        uint256 repay_amount,
        uint256 interestRateMode
    ) public onlyOwner {
        ERC20 token = ERC20(asset);
        token.safeApprove(address(aave_pool), repay_amount);
        aave_pool.repay(asset, repay_amount, interestRateMode, address(this));

        emit Repaid(asset, repay_amount, interestRateMode);
    }

    /// @notice Function to claim all rewards
    function claimAllRewards() external {
        address[] memory allTokens = aave_pool.getReservesList();
        AAVERewardsController.claimAllRewards(allTokens, address(this));

        emit RewardsClaimed();
    }

    /* ========== RESTRICTED GOVERNANCE FUNCTIONS ========== */

    /// @notice Function to return collateral to the minter
    /// @param collat_amount Amount of collateral to return to the minter
    function returnCollateralToMinter(uint256 collat_amount) public onlyOwner {
        ERC20 collateral_token = amo_minter.collateral_token();

        if (collat_amount == 0) {
            collat_amount = collateral_token.balanceOf(address(this));
        }

        // Approve collateral to UbiquityAMOMinter
        collateral_token.approve(address(amo_minter), collat_amount);

        // Call receiveCollatFromAMO from the UbiquityAMOMinter
        amo_minter.receiveCollatFromAMO(collat_amount);

        emit CollateralReturnedToMinter(collat_amount);
    }

    // Sets AMO minter
    function setAMOMinter(address _amo_minter_address) external onlyOwner {
        amo_minter = UbiquityAMOMinter(_amo_minter_address);

        emit AMOMinterSet(_amo_minter_address);
    }

    // Emergency ERC20 recovery function
    function recoverERC20(
        address tokenAddress,
        uint256 tokenAmount
    ) external onlyOwner {
        ERC20(tokenAddress).safeTransfer(msg.sender, tokenAmount);

        emit ERC20Recovered(tokenAddress, tokenAmount);
    }

    // Emergency generic proxy - allows owner to execute arbitrary calls on this contract
    function execute(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner returns (bool, bytes memory) {
        (bool success, bytes memory result) = _to.call{value: _value}(_data);

        emit ExecuteCalled(_to, _value, _data);
        return (success, result);
    }

    /* ========== EVENTS ========== */

    event CollateralDeposited(
        address indexed collateral_address,
        uint256 amount
    );
    event CollateralWithdrawn(
        address indexed collateral_address,
        uint256 amount
    );
    event Borrowed(
        address indexed asset,
        uint256 amount,
        uint256 interestRateMode
    );
    event Repaid(
        address indexed asset,
        uint256 amount,
        uint256 interestRateMode
    );
    event CollateralReturnedToMinter(uint256 amount);
    event RewardsClaimed();
    event AMOMinterSet(address indexed new_minter);
    event ERC20Recovered(address tokenAddress, uint256 tokenAmount);
    event ExecuteCalled(address indexed to, uint256 value, bytes data);
}
