// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MockUbiquityPool {
    bool public paused;
    uint256 public collateralUsdBalance;
    uint256 public collateralRatio;

    function pause() external {
        paused = true;
    }

    function unpause() external {
        paused = false;
    }

    function setCollateralUsdBalance(uint256 _balance) external {
        collateralUsdBalance = _balance;
    }

    function setCollateralRatio(uint256 _ratio) external {
        collateralRatio = _ratio;
    }
}
