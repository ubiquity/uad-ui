// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../../../src/dollar/libraries/LibDiamond.sol";
import "../../../src/dollar/libraries/LibAccessControl.sol";
import "../../../lib/chainlink-brownie-contracts/contracts/src/v0.8/AutomationCompatible.sol";
import "../../../src/dollar/interfaces/IUbiquityPool.sol";
import "../../../src/dollar/interfaces/IUbiquityDollarToken.sol";
import "../../../src/dollar/interfaces/ITelegramNotifier.sol";

contract SecurityMonitorFacet is
    ReentrancyGuard,
    AutomationCompatibleInterface
{
    using SafeMath for uint256;

    bytes32 public constant SECURITY_MONITOR_ROLE =
        keccak256("SECURITY_MONITOR_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 public constant LIQUIDITY_THRESHOLD = 70; // 70% of initial liquidity
    uint256 public constant COLLATERAL_RATIO_THRESHOLD = 900000; // 90% (using 1e6 precision)
    uint256 public constant LARGE_TRANSFER_THRESHOLD = 1000000e18; // 1 million dollars

    struct SecurityMonitorStorage {
        uint256 lastCheckTimestamp;
        uint256 checkInterval;
    }

    bytes32 constant SECURITY_MONITOR_STORAGE_POSITION =
        keccak256("security.monitor.storage");

    function securityMonitorStorage()
        internal
        pure
        returns (SecurityMonitorStorage storage s)
    {
        bytes32 position = SECURITY_MONITOR_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    event SecurityIncident(string message);

    function initialize(uint256 _checkInterval) external {
        LibDiamond.enforceIsContractOwner();
        SecurityMonitorStorage storage s = securityMonitorStorage();
        s.checkInterval = _checkInterval;
        s.lastCheckTimestamp = block.timestamp;
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        SecurityMonitorStorage storage s = securityMonitorStorage();

        upkeepNeeded =
            (block.timestamp - s.lastCheckTimestamp) >= s.checkInterval;

        performData = ""; // Return an empty bytes array
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        SecurityMonitorStorage storage s = securityMonitorStorage();

        if ((block.timestamp - s.lastCheckTimestamp) >= s.checkInterval) {
            s.lastCheckTimestamp = block.timestamp;

            checkSecurityConditions();
        }
    }

    function checkSecurityConditions() internal {
        if (checkLiquidity()) {
            handleSecurityIncident("Liquidity below threshold");
        }

        if (checkCollateralRatio()) {
            handleSecurityIncident("Collateral ratio below threshold");
        }

        // Add more security checks as needed
    }

    function handleSecurityIncident(
        string memory message
    ) internal nonReentrant {
        require(
            LibAccessControl.hasRole(SECURITY_MONITOR_ROLE, address(this)),
            "SecurityMonitor: not authorized"
        );

        // Pause the UbiquityDollarToken and UbiquityPoolFacet

        if (LibAccessControl.hasRole(PAUSER_ROLE, address(this))) {
            // Instead of directly calling pause(), we'll use a more generic approach

            // that should work regardless of how pausing is implemented in UbiquityDollarToken

            (bool success, ) = address(LibDiamond.contractOwner()).call(
                abi.encodeWithSignature("pauseDollarToken()")
            );

            require(success, "Failed to pause UbiquityDollarToken");

            IUbiquityPool(LibDiamond.contractOwner()).toggleMintRedeemBorrow(
                0,
                0
            ); // Pause minting

            IUbiquityPool(LibDiamond.contractOwner()).toggleMintRedeemBorrow(
                0,
                1
            ); // Pause redeeming

            emit SecurityIncident(message);

            ITelegramNotifier(LibDiamond.contractOwner()).notify(message);
        } else {
            emit SecurityIncident(
                "Failed to pause: SecurityMonitor lacks PAUSER_ROLE"
            );

            ITelegramNotifier(LibDiamond.contractOwner()).notify(
                "Failed to pause: SecurityMonitor lacks PAUSER_ROLE"
            );
        }
    }

    function checkLiquidity() internal view returns (bool) {
        uint256 poolLiquidity = IUbiquityPool(LibDiamond.contractOwner())
            .collateralUsdBalance();

        uint256 thresholdLiquidity = poolLiquidity.mul(LIQUIDITY_THRESHOLD).div(
            100
        );

        return poolLiquidity < thresholdLiquidity;
    }

    function checkCollateralRatio() internal view returns (bool) {
        uint256 currentRatio = IUbiquityPool(LibDiamond.contractOwner())
            .collateralRatio();

        return currentRatio < COLLATERAL_RATIO_THRESHOLD;
    }

    function setCheckInterval(uint256 _newInterval) external {
        LibDiamond.enforceIsContractOwner();

        SecurityMonitorStorage storage s = securityMonitorStorage();

        s.checkInterval = _newInterval;
    }
}
