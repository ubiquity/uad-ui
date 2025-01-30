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

    /**
     * @notice Instance of AccessControlFacet used for role-based access control.
     */
    AccessControlFacet public accessControlFacet;

    /**
     * @notice Instance of UbiquityPoolFacet used to interact with the pool's functionalities.
     */
    UbiquityPoolFacet public ubiquityPoolFacet;

    /**
     * @notice Instance of ManagerFacet used to interact with manager-related functionalities.
     */
    ManagerFacet public managerFacet;

    /**
     * @notice The highest recorded collateral liquidity value (in USD) used as a reference point.
     */
    uint256 public liquidityVertex;

    /**
     * @notice Flag indicating whether the liquidity monitor is paused.
     */
    bool public monitorPaused;

    /**
     * @notice The threshold percentage at which liquidity differences are considered critical.
     * @dev Default is set to 30%.
     */
    uint256 public thresholdPercentage;

    /**
     * @notice Emitted when the liquidity vertex is updated to a new value.
     * @param liquidityVertex The new liquidity vertex value (in USD).
     */
    event LiquidityVertexUpdated(uint256 liquidityVertex);

    /**
     * @notice Emitted when the liquidity vertex is manually dropped.
     * @param liquidityVertex The dropped liquidity vertex value (in USD).
     */
    event LiquidityVertexDropped(uint256 liquidityVertex);

    /**
     * @notice Emitted when the monitor pauses due to a liquidity drop exceeding the threshold.
     * @param collateralLiquidity The current collateral liquidity (in USD) when the monitor pauses.
     * @param diffPercentage The percentage difference between the current liquidity and the vertex.
     */
    event MonitorPaused(uint256 collateralLiquidity, uint256 diffPercentage);

    /**
     * @notice Emitted when the monitor's paused state is toggled.
     * @param paused Boolean flag indicating the new paused state (true = paused, false = active).
     */
    event PausedToggled(bool paused);

    /**
     * @notice Modifier that restricts access to functions to only addresses with the DEFENDER_RELAYER_ROLE.
     * @dev This role is required for relayer functions in the security monitor system.
     *      If the caller does not have the required role, the transaction is reverted.
     */
    modifier onlyDefender() {
        require(
            accessControlFacet.hasRole(DEFENDER_RELAYER_ROLE, msg.sender),
            "Ubiquity Pool Security Monitor: not defender relayer"
        );
        _;
    }

    /**
     * @notice Modifier that restricts access to functions to only addresses with the DEFAULT_ADMIN_ROLE.
     * @dev This role is needed for administrative tasks, such as managing settings or configurations.
     *      If the caller does not have the admin role, the transaction is reverted.
     */
    modifier onlyMonitorAdmin() {
        require(
            accessControlFacet.hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Ubiquity Pool Security Monitor: not admin"
        );
        _;
    }

    /**
     * @notice Initializes the UbiquityPoolSecurityMonitor contract.
     * @param _accessControlFacet The address of the AccessControlFacet contract for managing roles.
     * @param _ubiquityPoolFacet The address of the UbiquityPoolFacet contract for pool interactions.
     * @param _managerFacet The address of the ManagerFacet contract for manager-related interactions.
     * @dev Sets the default threshold percentage to 30% and assigns the provided facet contracts.
     *      This function is only called once during the initialization of the upgradeable contract.
     */
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

    /**
     * @notice Updates the ManagerFacet contract used by the monitor.
     * @param _newManagerFacet The address of the new ManagerFacet contract.
     * @dev This function is restricted to addresses with the DEFAULT_ADMIN_ROLE via the `onlyMonitorAdmin` modifier.
     */
    function setManagerFacet(
        address _newManagerFacet
    ) external onlyMonitorAdmin {
        managerFacet = ManagerFacet(_newManagerFacet);
    }

    /**
     * @notice Updates the UbiquityPoolFacet contract used by the monitor.
     * @param _newUbiquityPoolFacet The address of the new UbiquityPoolFacet contract.
     * @dev This function is restricted to addresses with the DEFAULT_ADMIN_ROLE via the `onlyMonitorAdmin` modifier.
     */
    function setUbiquityPoolFacet(
        address _newUbiquityPoolFacet
    ) external onlyMonitorAdmin {
        ubiquityPoolFacet = UbiquityPoolFacet(_newUbiquityPoolFacet);
    }

    /**
     * @notice Updates the AccessControlFacet contract used by the monitor.
     * @param _newAccessControlFacet The address of the new AccessControlFacet contract.
     * @dev This function is restricted to addresses with the DEFAULT_ADMIN_ROLE via the `onlyMonitorAdmin` modifier.
     */
    function setAccessControlFacet(
        address _newAccessControlFacet
    ) external onlyMonitorAdmin {
        accessControlFacet = AccessControlFacet(_newAccessControlFacet);
    }

    /**
     * @notice Updates the threshold percentage used to detect significant liquidity drops.
     * @param _newThresholdPercentage The new threshold percentage to be set.
     * @dev This function is restricted to addresses with the DEFAULT_ADMIN_ROLE via the `onlyMonitorAdmin` modifier.
     */
    function setThresholdPercentage(
        uint256 _newThresholdPercentage
    ) external onlyMonitorAdmin {
        thresholdPercentage = _newThresholdPercentage;
    }

    /**
     * @notice Toggles the paused state of the liquidity monitor.
     * @dev This function is restricted to addresses with the DEFAULT_ADMIN_ROLE via the `onlyMonitorAdmin` modifier.
     *      Emits the `PausedToggled` event with the updated paused state.
     */
    function togglePaused() external onlyMonitorAdmin {
        monitorPaused = !monitorPaused;
        emit PausedToggled(monitorPaused);
    }

    /**
     * @notice Resets the liquidity vertex to the current collateral liquidity in the pool.
     * @dev This function is used to restart the monitor and reset the liquidity vertex after a
     *      significant liquidity drop incident. It ensures that the new vertex is set to the
     *      current collateral liquidity.
     *      Emits the `LiquidityVertexDropped` event with the updated liquidity vertex value.
     *      Requires the current collateral liquidity to be greater than zero.
     * @dev This function is restricted to addresses with the DEFAULT_ADMIN_ROLE via the `onlyMonitorAdmin` modifier.
     */
    function dropLiquidityVertex() external onlyMonitorAdmin {
        uint256 currentCollateralLiquidity = ubiquityPoolFacet
            .collateralUsdBalance();
        require(currentCollateralLiquidity > 0, "Insufficient liquidity");

        liquidityVertex = currentCollateralLiquidity;

        emit LiquidityVertexDropped(liquidityVertex);
    }

    /**
     * @notice Checks the current collateral liquidity and compares it with the recorded liquidity vertex.
     * @dev This function ensures that the liquidity monitor is not paused and compares the current collateral
     *      liquidity in the pool against the stored liquidity vertex:
     *      - If the current liquidity exceeds the vertex, the vertex is updated.
     *      - If the current liquidity is below the vertex, the function checks whether the drop exceeds
     *        the configured threshold percentage.
     * @dev Requires the current collateral liquidity to be greater than zero and ensures the monitor is not paused.
     *      This function is restricted to addresses with the DEFENDER_RELAYER_ROLE via the `onlyDefender` modifier.
     */
    function checkLiquidityVertex() external onlyDefender {
        require(!monitorPaused, "Monitor paused");

        uint256 currentCollateralLiquidity = ubiquityPoolFacet
            .collateralUsdBalance();

        require(currentCollateralLiquidity > 0, "Insufficient liquidity");

        if (currentCollateralLiquidity > liquidityVertex) {
            _updateLiquidityVertex(currentCollateralLiquidity);
        } else if (currentCollateralLiquidity < liquidityVertex) {
            _checkThresholdPercentage(currentCollateralLiquidity);
        }
    }

    /**
     * @notice Updates the liquidity vertex to a new value when the current liquidity reaches a new higher value.
     * @param _newLiquidityVertex The new collateral liquidity value to set as the liquidity vertex.
     * @dev This internal function updates the recorded liquidity vertex to the provided value and
     *      emits the `LiquidityVertexUpdated` event. It is used when the current collateral liquidity
     *      exceeds the previously recorded vertex, ensuring that the vertex always reflects the highest
     *      observed liquidity level.
     */
    function _updateLiquidityVertex(uint256 _newLiquidityVertex) internal {
        liquidityVertex = _newLiquidityVertex;
        emit LiquidityVertexUpdated(liquidityVertex);
    }

    /**
     * @notice Checks if the difference between the current collateral liquidity and the liquidity vertex
     *         exceeds the configured threshold percentage.
     * @param _currentCollateralLiquidity The current collateral liquidity in the pool.
     * @dev This internal function is used when the current collateral liquidity is lower than the
     *      recorded liquidity vertex. It calculates the percentage difference and, if the difference
     *      exceeds the threshold percentage, the monitor is paused, the UbiquityDollarToken is paused,
     *      and collateral in the Ubiquity Pool is disabled.
     *      Emits the `MonitorPaused` event when the monitor is paused due to a significant liquidity drop.
     *      This event is caught by the defender monitor, which alerts about the liquidity issue after detecting it.
     */
    function _checkThresholdPercentage(
        uint256 _currentCollateralLiquidity
    ) internal {
        uint256 liquidityDiffPercentage = liquidityVertex
            .sub(_currentCollateralLiquidity)
            .mul(100)
            .div(liquidityVertex);

        if (liquidityDiffPercentage >= thresholdPercentage) {
            monitorPaused = true;

            // Pause the UbiquityDollarToken
            _pauseUbiquityDollarToken();

            // Pause LibUbiquityPool by disabling collateral
            _pauseLibUbiquityPool();

            emit MonitorPaused(
                _currentCollateralLiquidity,
                liquidityDiffPercentage
            );
        }
    }

    /**
     * @notice Pauses all collaterals in the Ubiquity Pool.
     * @dev This internal function retrieves all collateral addresses from the UbiquityPoolFacet
     *      and attempts to pause each collateral by toggling its state. If any collateral information
     *      cannot be retrieved, it is assumed that the collateral may already be paused, and the function
     *      continues to the next collateral without reverting.
     *      The purpose of this function is to disable all collateral operations when a significant
     *      liquidity issue is detected and the monitor is paused.
     */
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
                // Assume collateral is already paused if information cannot be retrieved
                continue;
            }
        }
    }

    /**
     * @notice Pauses the UbiquityDollarToken.
     * @dev This internal function pauses the UbiquityDollarToken by calling its `pause` function.
     *      It retrieves the UbiquityDollarToken contract address via the ManagerFacet and pauses it
     *      to prevent further transactions involving the dollar token during a significant liquidity issue.
     */
    function _pauseUbiquityDollarToken() internal {
        ERC20Ubiquity dollar = ERC20Ubiquity(managerFacet.dollarTokenAddress());
        dollar.pause();
    }

    /**
     * @notice Authorizes an upgrade to a new contract implementation.
     * @param newImplementation The address of the new implementation contract.
     * @dev This function is protected by the `onlyMonitorAdmin` modifier, meaning only an admin
     *      can authorize contract upgrades. This is an internal function that overrides UUPSUpgradeable's
     *      _authorizeUpgrade function.
     */
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyMonitorAdmin {}
}
