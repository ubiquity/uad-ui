// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {IUbiquityPool} from "../interfaces/IUbiquityPool.sol";
import {IUbiquityDollarToken} from "../interfaces/IUbiquityDollarToken.sol";

contract SecurityMonitor is ReentrancyGuard, AccessControl {
    using SafeMath for uint256;

    bytes32 public constant SECURITY_MONITOR_ROLE =
        keccak256("SECURITY_MONITOR_ROLE");
    uint256 public constant LIQUIDITY_THRESHOLD_PERCENT = 70; // 70% of initial liquidity
    uint256 public constant COLLATERAL_RATIO_THRESHOLD = 900000; // 90% (using 1e6 precision)

    struct SecurityMonitorStorage {
        uint256 lastCheckTimestamp;
        uint256 checkInterval;
        uint256 initialLiquidity;
    }

    SecurityMonitorStorage private _securityStorage;
    IUbiquityDollarToken public uDollarToken;
    IUbiquityPool public uPool;

    event SecurityIncident(string message);
    event DefenderAlert(string message);

    constructor(
        address _uDollarToken,
        address _uPool,
        uint256 _checkInterval,
        uint256 _initialLiquidity
    ) {
        uDollarToken = IUbiquityDollarToken(_uDollarToken);
        uPool = IUbiquityPool(_uPool);
        _securityStorage.checkInterval = _checkInterval;
        _securityStorage.lastCheckTimestamp = block.timestamp;
        _securityStorage.initialLiquidity = _initialLiquidity;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(SECURITY_MONITOR_ROLE, msg.sender);
    }

    function getCheckInterval() external view returns (uint256) {
        return _securityStorage.checkInterval;
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    ) external view returns (bool upkeepNeeded) {
        upkeepNeeded =
            (block.timestamp - _securityStorage.lastCheckTimestamp) >=
            _securityStorage.checkInterval;
    }

    function performUpkeep() external {
        require(
            hasRole(SECURITY_MONITOR_ROLE, msg.sender),
            "SecurityMonitor: not authorized"
        );
        if (
            (block.timestamp - _securityStorage.lastCheckTimestamp) >=
            _securityStorage.checkInterval
        ) {
            _securityStorage.lastCheckTimestamp = block.timestamp;
            _checkSecurityConditions();
        }
    }

    function _checkSecurityConditions() internal {
        if (_checkLiquidity()) {
            _handleSecurityIncident("Liquidity below threshold");
        }
        if (_checkCollateralRatio()) {
            _handleSecurityIncident("Collateral ratio below threshold");
        }
    }

    function _handleSecurityIncident(
        string memory message
    ) internal nonReentrant {
        emit SecurityIncident(message);
        uDollarToken.pause();
        uPool.pause();
        _emitDefenderAlert(message);
    }

    function _checkLiquidity() internal view returns (bool) {
        uint256 poolLiquidity = uPool.collateralUsdBalance();
        uint256 thresholdLiquidity = _securityStorage
            .initialLiquidity
            .mul(LIQUIDITY_THRESHOLD_PERCENT)
            .div(100);
        return poolLiquidity < thresholdLiquidity;
    }

    function _checkCollateralRatio() internal view returns (bool) {
        uint256 currentRatio = uPool.collateralRatio();
        return currentRatio < COLLATERAL_RATIO_THRESHOLD;
    }

    function setCheckInterval(uint256 _newInterval) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "SecurityMonitor: not authorized"
        );
        _securityStorage.checkInterval = _newInterval;
    }

    function _emitDefenderAlert(string memory message) internal {
        emit DefenderAlert(message);
    }
}
