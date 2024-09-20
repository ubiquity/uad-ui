// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlFacet} from "../facets/AccessControlFacet.sol";
import {UbiquityPoolFacet} from "../facets/UbiquityPoolFacet.sol";
import {LibUbiquityPool} from "../libraries/LibUbiquityPool.sol";
import {ERC20Ubiquity} from "./ERC20Ubiquity.sol";
import {ManagerFacet} from "../facets/ManagerFacet.sol";
import "../libraries/Constants.sol";
import "forge-std/console.sol";

contract UbiquityPoolSecurityMonitor is Initializable, UUPSUpgradeable {
    using SafeMath for uint256;

    AccessControlFacet public accessControlFacet;
    UbiquityPoolFacet public ubiquityPoolFacet;
    ManagerFacet public managerFacet;
    uint256 public liquidityVertex;
    bool public monitorPaused;
    uint256 public thresholdPercentage;

    event LiquidityVertexUpdated(uint256 collateralLiquidity);
    event MonitorPaused(uint256 collateralLiquidity, uint256 diffPercentage);
    event VertexDropped();
    event PausedToggled(bool paused);

    modifier onlyDefender() {
        require(
            accessControlFacet.hasRole(DEFENDER_RELAYER_ROLE, msg.sender),
            "Ubiquity Pool Security Monitor: not defender relayer"
        );
        _;
    }

    modifier onlyMonitorAdmin() {
        require(
            accessControlFacet.hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Ubiquity Pool Security Monitor: not admin"
        );
        _;
    }

    function initialize(
        address _accessControlFacet,
        address _ubiquityPoolFacet,
        address _managerFacet
    ) public initializer {
        thresholdPercentage = 30;

        accessControlFacet = AccessControlFacet(_accessControlFacet);
        ubiquityPoolFacet = UbiquityPoolFacet(_ubiquityPoolFacet);
        managerFacet = ManagerFacet(_managerFacet);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyMonitorAdmin {}

    function setManagerFacet(
        address _newManagerFacet
    ) external onlyMonitorAdmin {
        managerFacet = ManagerFacet(_newManagerFacet);
    }

    function setUbiquityPoolFacet(
        address _newUbiquityPoolFacet
    ) external onlyMonitorAdmin {
        ubiquityPoolFacet = UbiquityPoolFacet(_newUbiquityPoolFacet);
    }

    function setAccessControlFacet(
        address _newAccessControlFacet
    ) external onlyMonitorAdmin {
        accessControlFacet = AccessControlFacet(_newAccessControlFacet);
    }

    function setThresholdPercentage(
        uint256 _newThresholdPercentage
    ) external onlyMonitorAdmin {
        thresholdPercentage = _newThresholdPercentage;
    }

    function togglePaused() external onlyMonitorAdmin {
        monitorPaused = !monitorPaused;
        emit PausedToggled(monitorPaused);
    }

    function dropLiquidityVertex() external onlyMonitorAdmin {
        uint256 currentCollateralLiquidity = ubiquityPoolFacet
            .collateralUsdBalance();
        require(currentCollateralLiquidity > 0, "Insufficient liquidity");

        liquidityVertex = currentCollateralLiquidity;

        emit VertexDropped();
    }

    function checkLiquidityVertex() external onlyDefender {
        uint256 currentCollateralLiquidity = ubiquityPoolFacet
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
                _pauseUbiquityDollarToken();

                // Pause LibUbiquityPool by disabling collateral
                _pauseLibUbiquityPool();

                emit MonitorPaused(
                    currentCollateralLiquidity,
                    liquidityDiffPercentage
                );
            }
        }
    }

    function _pauseLibUbiquityPool() internal {
        address[] memory allCollaterals = ubiquityPoolFacet.allCollaterals();

        for (uint256 i = 0; i < allCollaterals.length; i++) {
            try
                ubiquityPoolFacet.collateralInformation(allCollaterals[i])
            returns (
                LibUbiquityPool.CollateralInformation memory collateralInfo
            ) {
                ubiquityPoolFacet.toggleCollateral(collateralInfo.index);
            } catch {
                continue;
            }
        }
    }

    function _pauseUbiquityDollarToken() internal {
        ERC20Ubiquity dollarToken = ERC20Ubiquity(
            managerFacet.dollarTokenAddress()
        );
        dollarToken.pause();
    }
}
