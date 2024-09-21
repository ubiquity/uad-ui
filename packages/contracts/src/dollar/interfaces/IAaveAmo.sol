// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IAaveAmo {
    /**
     * @notice Deposits collateral into the Aave pool
     * @param collateralAddress Address of the collateral ERC20 token
     * @param amount Amount of collateral to deposit
     */
    function aaveDepositCollateral(
        address collateralAddress,
        uint256 amount
    ) external;

    /**
     * @notice Withdraws collateral from the Aave pool
     * @param collateralAddress Address of the collateral ERC20 token
     * @param aTokenAmount Amount of aTokens (collateral) to withdraw
     */
    function aaveWithdrawCollateral(
        address collateralAddress,
        uint256 aTokenAmount
    ) external;

    /**
     * @notice Borrows an asset from the Aave pool
     * @param asset Address of the asset to borrow
     * @param borrowAmount Amount of the asset to borrow
     * @param interestRateMode Interest rate mode: 1 for stable, 2 for variable
     */
    function aaveBorrow(
        address asset,
        uint256 borrowAmount,
        uint256 interestRateMode
    ) external;

    /**
     * @notice Repays a borrowed asset to the Aave pool
     * @param asset Address of the asset to repay
     * @param repayAmount Amount of the asset to repay
     * @param interestRateMode Interest rate mode: 1 for stable, 2 for variable
     */
    function aaveRepay(
        address asset,
        uint256 repayAmount,
        uint256 interestRateMode
    ) external;

    /**
     * @notice Claims all rewards from the provided assets
     * @param assets Array of aTokens/sTokens/vTokens addresses to claim rewards from
     */
    function claimAllRewards(address[] memory assets) external;

    /**
     * @notice Returns collateral back to the AMO minter
     * @param collateralAmount Amount of collateral to return
     */
    function returnCollateralToMinter(uint256 collateralAmount) external;

    /**
     * @notice Sets the address of the AMO minter
     * @param _amoMinterAddress New address of the AMO minter
     */
    function setAmoMinter(address _amoMinterAddress) external;

    /**
     * @notice Recovers any ERC20 tokens held by the contract
     * @param tokenAddress Address of the token to recover
     * @param tokenAmount Amount of tokens to recover
     */
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external;

    /**
     * @notice Executes an arbitrary call from the contract
     * @param _to Address to call
     * @param _value Value to send with the call
     * @param _data Data to execute in the call
     * @return success Boolean indicating whether the call succeeded
     * @return result Bytes data returned from the call
     */
    function execute(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external returns (bool, bytes memory);

    /**
     * @notice Emitted when collateral is deposited into the Aave pool
     * @param collateralAddress Address of the collateral token
     * @param amount Amount of collateral deposited
     */
    event CollateralDeposited(
        address indexed collateralAddress,
        uint256 amount
    );

    /**
     * @notice Emitted when collateral is withdrawn from the Aave pool
     * @param collateralAddress Address of the collateral token
     * @param amount Amount of collateral withdrawn
     */
    event CollateralWithdrawn(
        address indexed collateralAddress,
        uint256 amount
    );

    /**
     * @notice Emitted when an asset is borrowed from the Aave pool
     * @param asset Address of the asset borrowed
     * @param amount Amount of asset borrowed
     * @param interestRateMode Interest rate mode used for the borrow (1 for stable, 2 for variable)
     */
    event Borrowed(
        address indexed asset,
        uint256 amount,
        uint256 interestRateMode
    );

    /**
     * @notice Emitted when a borrowed asset is repaid to the Aave pool
     * @param asset Address of the asset repaid
     * @param amount Amount of asset repaid
     * @param interestRateMode Interest rate mode used for the repay (1 for stable, 2 for variable)
     */
    event Repaid(
        address indexed asset,
        uint256 amount,
        uint256 interestRateMode
    );

    /**
     * @notice Emitted when collateral is returned to the AMO minter
     * @param amount Amount of collateral returned
     */
    event CollateralReturnedToMinter(uint256 amount);

    /**
     * @notice Emitted when rewards are claimed
     */
    event RewardsClaimed();

    /**
     * @notice Emitted when the AMO minter address is set
     * @param newMinter Address of the new AMO minter
     */
    event AmoMinterSet(address indexed newMinter);

    /**
     * @notice Emitted when ERC20 tokens are recovered from the contract
     * @param tokenAddress Address of the recovered token
     * @param tokenAmount Amount of tokens recovered
     */
    event ERC20Recovered(address tokenAddress, uint256 tokenAmount);

    /**
     * @notice Emitted when an arbitrary call is executed from the contract
     * @param to Address of the call target
     * @param value Value sent with the call
     * @param data Data sent with the call
     */
    event ExecuteCalled(address indexed to, uint256 value, bytes data);
}
