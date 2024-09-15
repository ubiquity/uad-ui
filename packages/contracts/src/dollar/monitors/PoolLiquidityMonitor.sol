// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Modifiers} from "../libraries/LibAppStorage.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {DEFAULT_ADMIN_ROLE} from "../libraries/Constants.sol";
import {LibUbiquityPool} from "../libraries/LibUbiquityPool.sol";
import "forge-std/console.sol";

contract PoolLiquidityMonitor is Modifiers {
    using SafeMath for uint256;

    address public defenderRelayer;
    uint256 public liquidityVertex;
    bool public monitorPaused;
    uint256 public thresholdPercentage;

    event LiquidityVertexUpdated(uint256 collateralLiquidity);
    event MonitorPaused(uint256 collateralLiquidity, uint256 diffPercentage);
    event VertexDropped();
    event PausedToggled(bool paused);

    modifier onlyAuthorized() {
        require(
            msg.sender == defenderRelayer,
            "Not authorized: Only Defender Relayer allowed"
        );
        _;
    }

    function setThresholdPercentage(
        uint256 _newThresholdPercentage
    ) external onlyAdmin {
        thresholdPercentage = _newThresholdPercentage;
    }

    function setDefenderRelayer(
        address _newDefenderRelayer
    ) external onlyAdmin {
        defenderRelayer = _newDefenderRelayer;
    }

    function togglePaused() external onlyAdmin {
        monitorPaused = !monitorPaused;
        emit PausedToggled(monitorPaused);
    }

    function dropLiquidityVertex() external onlyAdmin {
        uint256 currentCollateralLiquidity = LibUbiquityPool
            .collateralUsdBalance();

        require(currentCollateralLiquidity > 0, "Insufficient liquidity");

        liquidityVertex = currentCollateralLiquidity;

        emit VertexDropped();
    }

    function checkLiquidityVertex() external onlyAuthorized {
        uint256 currentCollateralLiquidity = LibUbiquityPool
            .collateralUsdBalance();

        require(currentCollateralLiquidity > 0, "Insufficient liquidity");
        require(!monitorPaused, "Monitor paused");

        if (currentCollateralLiquidity > liquidityVertex) {
            liquidityVertex = currentCollateralLiquidity;

            emit LiquidityVertexUpdated(liquidityVertex);
        } else {
            uint256 liquidityDiffPercentage = liquidityVertex
                .sub(currentCollateralLiquidity)
                .mul(100)
                .div(liquidityVertex);

            if (liquidityDiffPercentage >= thresholdPercentage) {
                monitorPaused = true;

                // Pause the UbiquityDollarToken
                // Pause LibUbiquityPool by disabling collateral

                emit MonitorPaused(
                    currentCollateralLiquidity,
                    liquidityDiffPercentage
                );
            }
        }
    }
}
