// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {UbiquityAMOMinter} from "../core/UbiquityAMOMinter.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IPool} from "@aavev3-core/contracts/interfaces/IPool.sol";
import {IPoolDataProvider} from "@aavev3-core/contracts/interfaces/IPoolDataProvider.sol";
import {IRewardsController} from "@aavev3-periphery/contracts/rewards/interfaces/IRewardsController.sol";

/**
 * @title AaveAMO
 * @notice AMO to interact with Aave V3 and manage rewards and borrowing mechanisms.
 * @notice Can receive collateral from Ubiquity AMO minter and interact with Aave's V3 pool.
 */
contract AaveAMO is Ownable {
    using SafeERC20 for ERC20;

    /// @notice Ubiquity AMO minter instance
    UbiquityAMOMinter public amo_minter;

    /// @notice Aave V3 pool instance
    IPool public immutable aave_pool;

    /// @notice AAVE token address
    ERC20 public immutable AAVE;

    /// @notice AAVE rewards controller
    IRewardsController public immutable AAVERewardsController;

    /// @notice AAVE data provider
    IPoolDataProvider public immutable AAVEPoolDataProvider;

    /// @notice List of borrowed assets from Aave
    address[] public aave_borrow_asset_list;

    /// @notice Mapping for tracking borrowed assets
    mapping(address => bool) public aave_borrow_asset_check;

    /* ========== CONSTRUCTOR ========== */

    /**
     * @notice Initializes the contract with necessary parameters
     * @param _owner_address Address of the contract owner
     * @param _amo_minter_address Address of the Ubiquity AMO minter
     * @param _aave_pool Address of the Aave pool
     * @param _aave Address of the AAVE token
     * @param _aave_rewards_controller Address of the AAVE rewards controller
     * @param _aave_pool_data_provider Address of the AAVE data provider
     */
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

        // Set contract owner
        transferOwnership(_owner_address);

        // Set the AMO minter
        amo_minter = UbiquityAMOMinter(_amo_minter_address);

        // Set the Aave pool
        aave_pool = IPool(_aave_pool);

        // Set the AAVE token
        AAVE = ERC20(_aave);

        // Set the AAVE rewards controller
        AAVERewardsController = IRewardsController(_aave_rewards_controller);

        // Set the AAVE pool data provider
        AAVEPoolDataProvider = IPoolDataProvider(_aave_pool_data_provider);
    }

    /* ========== MODIFIERS ========== */

    /**
     * @notice Ensures the caller is the AMO minter
     */
    modifier onlyByMinter() {
        require(msg.sender == address(amo_minter), "Not minter");
        _;
    }

    /* ========== AAVE V3 + REWARDS ========== */

    /**
     * @notice Deposits collateral to Aave pool
     * @param collateral_address Address of the collateral ERC20
     * @param amount Amount of collateral to deposit
     */
    function aaveDepositCollateral(
        address collateral_address,
        uint256 amount
    ) public onlyOwner {
        ERC20 token = ERC20(collateral_address);
        token.safeApprove(address(aave_pool), amount);
        aave_pool.deposit(collateral_address, amount, address(this), 0);

        emit CollateralDeposited(collateral_address, amount);
    }

    /**
     * @notice Withdraws collateral from Aave pool
     * @param collateral_address Address of the collateral ERC20
     * @param aToken_amount Amount of collateral to withdraw
     */
    function aaveWithdrawCollateral(
        address collateral_address,
        uint256 aToken_amount
    ) public onlyOwner {
        aave_pool.withdraw(collateral_address, aToken_amount, address(this));

        emit CollateralWithdrawn(collateral_address, aToken_amount);
    }

    /**
     * @notice Borrows an asset from Aave pool
     * @param asset Address of the asset to borrow
     * @param borrow_amount Amount of asset to borrow
     * @param interestRateMode Interest rate mode: 1 for Stable, 2 for Variable
     */
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

    /**
     * @notice Repays a borrowed asset to Aave pool
     * @param asset Address of the asset to repay
     * @param repay_amount Amount of asset to repay
     * @param interestRateMode Interest rate mode: 1 for Stable, 2 for Variable
     */
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

    /**
     * @notice Claims all rewards from Aave
     */
    function claimAllRewards() external {
        address[] memory allTokens = aave_pool.getReservesList();
        AAVERewardsController.claimAllRewards(allTokens, address(this));

        emit RewardsClaimed();
    }

    /* ========== RESTRICTED GOVERNANCE FUNCTIONS ========== */

    /**
     * @notice Returns collateral back to the AMO minter
     * @param collat_amount Amount of collateral to return
     */
    function returnCollateralToMinter(uint256 collat_amount) public onlyOwner {
        ERC20 collateral_token = amo_minter.collateral_token();

        if (collat_amount == 0) {
            collat_amount = collateral_token.balanceOf(address(this));
        }

        // Approve and return collateral
        collateral_token.approve(address(amo_minter), collat_amount);
        amo_minter.receiveCollatFromAMO(collat_amount);

        emit CollateralReturnedToMinter(collat_amount);
    }

    /**
     * @notice Sets the AMO minter address
     * @param _amo_minter_address New address of the AMO minter
     */
    function setAMOMinter(address _amo_minter_address) external onlyOwner {
        amo_minter = UbiquityAMOMinter(_amo_minter_address);

        emit AMOMinterSet(_amo_minter_address);
    }

    /**
     * @notice Recovers any ERC20 tokens held by the contract
     * @param tokenAddress Address of the token to recover
     * @param tokenAmount Amount of tokens to recover
     */
    function recoverERC20(
        address tokenAddress,
        uint256 tokenAmount
    ) external onlyOwner {
        ERC20(tokenAddress).safeTransfer(msg.sender, tokenAmount);

        emit ERC20Recovered(tokenAddress, tokenAmount);
    }

    /**
     * @notice Executes arbitrary calls from this contract
     * @param _to Address to call
     * @param _value Value to send
     * @param _data Data to execute
     * @return success, result Returns whether the call succeeded and the returned data
     */
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
