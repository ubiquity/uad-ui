// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import {UbiquityAmoMinter} from "../core/UbiquityAmoMinter.sol";
import {IAmo} from "../interfaces/IAmo.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IPool} from "@aavev3-core/contracts/interfaces/IPool.sol";
import {IRewardsController} from "@aavev3-periphery/contracts/rewards/interfaces/IRewardsController.sol";

/**
 * @title AaveAmo
 * @notice AMO to interact with Aave V3: supply and manage rewards.
 * @notice Can receive collateral from UbiquityAmoMinter and interact with Aave's V3 pool.
 */
contract AaveAmo is IAmo, Ownable {
    using SafeERC20 for ERC20;

    /// @notice UbiquityAmoMinter instance
    UbiquityAmoMinter public amoMinter;

    /// @notice Aave V3 pool instance
    IPool public immutable aavePool;

    /// @notice Aave rewards controller
    IRewardsController public immutable aaveRewardsController;

    /* ========== CONSTRUCTOR ========== */

    /**
     * @notice Initializes the contract with necessary parameters
     * @param _ownerAddress Address of the contract owner
     * @param _amoMinterAddress Address of the Ubiquity Amo minter
     * @param _aavePool Address of the Aave pool
     * @param _aaveRewardsController Address of the Aave rewards controller
     */
    constructor(
        address _ownerAddress,
        address _amoMinterAddress,
        address _aavePool,
        address _aaveRewardsController
    ) {
        require(_ownerAddress != address(0), "Owner address cannot be zero");
        require(
            _amoMinterAddress != address(0),
            "Amo minter address cannot be zero"
        );
        require(_aavePool != address(0), "Aave pool address cannot be zero");
        require(
            _aaveRewardsController != address(0),
            "Aave rewards controller address cannot be zero"
        );

        // Set contract owner
        transferOwnership(_ownerAddress);

        // Set the Amo minter
        amoMinter = UbiquityAmoMinter(_amoMinterAddress);

        // Set the Aave pool
        aavePool = IPool(_aavePool);

        // Set the Aave rewards controller
        aaveRewardsController = IRewardsController(_aaveRewardsController);
    }

    /* ========== Aave V3 + REWARDS ========== */

    /**
     * @notice Deposits collateral to Aave pool
     * @param collateralAddress Address of the collateral ERC20
     * @param amount Amount of collateral to deposit
     */
    function aaveDepositCollateral(
        address collateralAddress,
        uint256 amount
    ) public onlyOwner {
        ERC20 token = ERC20(collateralAddress);
        token.safeApprove(address(aavePool), amount);
        aavePool.deposit(collateralAddress, amount, address(this), 0);

        emit CollateralDeposited(collateralAddress, amount);
    }

    /**
     * @notice Withdraws collateral from Aave pool
     * @param collateralAddress Address of the collateral ERC20
     * @param aTokenAmount Amount of collateral to withdraw
     */
    function aaveWithdrawCollateral(
        address collateralAddress,
        uint256 aTokenAmount
    ) public onlyOwner {
        aavePool.withdraw(collateralAddress, aTokenAmount, address(this));

        emit CollateralWithdrawn(collateralAddress, aTokenAmount);
    }

    /**
     * @notice Claims all rewards available from the list of assets provided, will fail if balance on asset is zero
     * @param assets Array of aTokens/sTokens/vTokens addresses to claim rewards from
     */
    function claimAllRewards(address[] memory assets) external {
        // Claim all rewards for the collected tokens
        aaveRewardsController.claimAllRewards(assets, address(this));

        emit RewardsClaimed();
    }

    /* ========== RESTRICTED GOVERNANCE FUNCTIONS ========== */

    /**
     * @notice Returns collateral back to the AMO minter
     * @param collateralAmount Amount of collateral to return, pass 0 to return all collateral
     */
    function returnCollateralToMinter(
        uint256 collateralAmount
    ) public override onlyOwner {
        ERC20 collateralToken = amoMinter.collateralToken();

        if (collateralAmount == 0) {
            collateralAmount = collateralToken.balanceOf(address(this));
        }

        // Approve and return collateral
        collateralToken.approve(address(amoMinter), collateralAmount);
        amoMinter.receiveCollateralFromAmo(collateralAmount);

        emit CollateralReturnedToMinter(collateralAmount);
    }

    /**
     * @notice Sets the AMO minter address
     * @param _amoMinterAddress New address of the AMO minter
     */
    function setAmoMinter(
        address _amoMinterAddress
    ) external override onlyOwner {
        amoMinter = UbiquityAmoMinter(_amoMinterAddress);

        emit AmoMinterSet(_amoMinterAddress);
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
        address indexed collateralAddress,
        uint256 amount
    );
    event CollateralWithdrawn(
        address indexed collateralAddress,
        uint256 amount
    );
    event CollateralReturnedToMinter(uint256 amount);
    event RewardsClaimed();
    event AmoMinterSet(address indexed newMinter);
    event ERC20Recovered(address tokenAddress, uint256 tokenAmount);
    event ExecuteCalled(address indexed to, uint256 value, bytes data);
}
