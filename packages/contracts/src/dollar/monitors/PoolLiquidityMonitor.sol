// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../facets/UbiquityPoolFacet.sol";
import {Modifiers} from "../libraries/LibAppStorage.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PoolLiquidityMonitor is Modifiers {
    using SafeMath for uint256;

    UbiquityPoolFacet public immutable ubiquityPoolFacet;
    address public defenderRelayer;
    uint256 public liquidityVertex;
    bool public paused;
    uint256 public thresholdPercentage;

    event LiquidityVertexUpdated(uint256 collateralLiquidity);
    event MonitorPaused(uint256 collateralLiquidity, uint256 diffPercentage);
    event VertexDropped();
    event PausedToggled(bool paused);

    constructor(
        address _ubiquityPoolFacetAddress,
        address _defenderRelayer,
        uint256 _thresholdPercentage
    ) {
        ubiquityPoolFacet = UbiquityPoolFacet(_ubiquityPoolFacetAddress);
        defenderRelayer = _defenderRelayer;
        thresholdPercentage = _thresholdPercentage;
    }

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
        paused = !paused;
        emit PausedToggled(paused);
    }

    function dropLiquidityVertex() external onlyAdmin {
        uint256 currentCollateralLiquidity = ubiquityPoolFacet
            .collateralUsdBalance();

        require(currentCollateralLiquidity > 0, "Insufficient liquidity");

        liquidityVertex = currentCollateralLiquidity;

        emit VertexDropped();
    }

    function checkLiquidityVertex() external onlyAuthorized {
        uint256 currentCollateralLiquidity = ubiquityPoolFacet
            .collateralUsdBalance();

        require(currentCollateralLiquidity > 0, "Insufficient liquidity");
        require(!paused, "Monitor paused");

        if (currentCollateralLiquidity > liquidityVertex) {
            liquidityVertex = currentCollateralLiquidity;

            emit LiquidityVertexUpdated(liquidityVertex);
        } else {
            uint256 liquidityDiffPercentage = liquidityVertex
                .sub(currentCollateralLiquidity)
                .mul(100)
                .div(liquidityVertex);

            if (liquidityDiffPercentage >= thresholdPercentage) {
                paused = true;

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
