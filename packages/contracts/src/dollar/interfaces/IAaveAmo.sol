// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IAaveAmo {
    /* ========== AAVE V3 + REWARDS ========== */

    function aaveDepositCollateral(
        address collateralAddress,
        uint256 amount
    ) external;

    function aaveWithdrawCollateral(
        address collateralAddress,
        uint256 aToken_amount
    ) external;

    function aaveBorrow(
        address asset,
        uint256 borrowAmount,
        uint256 interestRateMode
    ) external;

    function aaveRepay(
        address asset,
        uint256 repayAmount,
        uint256 interestRateMode
    ) external;

    function claimAllRewards(address[] memory assets) external;

    /* ========== RESTRICTED GOVERNANCE FUNCTIONS ========== */

    function returnCollateralToMinter(uint256 collateralAmount) external;

    function setAmoMinter(address _amoMinterAddress) external;

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external;

    function execute(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external returns (bool, bytes memory);

    /* ========== EVENTS ========== */

    event CollateralDeposited(
        address indexed collateralAddress,
        uint256 amount
    );
    event CollateralWithdrawn(
        address indexed collateralAddress,
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
    event AmoMinterSet(address indexed newMinter);
    event ERC20Recovered(address tokenAddress, uint256 tokenAmount);
    event ExecuteCalled(address indexed to, uint256 value, bytes data);
}
