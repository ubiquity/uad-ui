// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../../../src/dollar/utils/SecurityMonitor.sol";
import "../../../src/dollar/mocks/MockUbiquityDollarToken.sol";
import "../../../src/dollar/mocks/MockUbiquityPool.sol";

contract SecurityMonitorTest is Test {
    SecurityMonitor public securityMonitor;
    MockUbiquityDollarToken public mockUDollarToken;
    MockUbiquityPool public mockUPool;

    address public admin = address(0x1);
    address public user = address(0x2);
    uint256 public constant CHECK_INTERVAL = 3600; // 1 hour
    uint256 public constant INITIAL_LIQUIDITY = 1000;

    function setUp() public {
        vm.startPrank(admin);
        mockUDollarToken = new MockUbiquityDollarToken();
        mockUPool = new MockUbiquityPool();

        mockUPool.setCollateralUsdBalance(INITIAL_LIQUIDITY);

        securityMonitor = new SecurityMonitor(
            address(mockUDollarToken),
            address(mockUPool),
            CHECK_INTERVAL,
            INITIAL_LIQUIDITY
        );
        securityMonitor.grantRole(
            securityMonitor.SECURITY_MONITOR_ROLE(),
            user
        );
        vm.stopPrank();
    }

    function testInitialState() public {
        assertEq(
            address(securityMonitor.uDollarToken()),
            address(mockUDollarToken)
        );
        assertEq(address(securityMonitor.uPool()), address(mockUPool));
        assertTrue(
            securityMonitor.hasRole(securityMonitor.DEFAULT_ADMIN_ROLE(), admin)
        );
        assertTrue(
            securityMonitor.hasRole(
                securityMonitor.SECURITY_MONITOR_ROLE(),
                user
            )
        );
    }

    function testCheckUpkeep() public {
        bool upkeepNeeded = securityMonitor.checkUpkeep("");
        assertFalse(upkeepNeeded);

        vm.warp(block.timestamp + CHECK_INTERVAL + 1);
        upkeepNeeded = securityMonitor.checkUpkeep("");
        assertTrue(upkeepNeeded);
    }

    function testPerformUpkeepUnauthorized() public {
        vm.expectRevert("SecurityMonitor: not authorized");
        securityMonitor.performUpkeep();
    }

    function testPerformUpkeepAuthorized() public {
        vm.warp(block.timestamp + CHECK_INTERVAL + 1);

        // Check that upkeep is needed before performing it
        bool upkeepNeededBefore = securityMonitor.checkUpkeep("");
        assertTrue(
            upkeepNeededBefore,
            "Upkeep should be needed before performUpkeep"
        );

        vm.prank(user);
        securityMonitor.performUpkeep();

        // Check that upkeep is not needed immediately after performing it
        bool upkeepNeededAfter = securityMonitor.checkUpkeep("");
        assertFalse(
            upkeepNeededAfter,
            "Upkeep should not be needed immediately after performUpkeep"
        );
    }

    function testSecurityIncidentLiquidity() public {
        mockUPool.setCollateralUsdBalance(50); // Set a low balance to trigger the incident

        vm.warp(block.timestamp + CHECK_INTERVAL + 1);
        vm.prank(user);

        vm.expectEmit(true, false, false, true);
        emit SecurityIncident("Liquidity below threshold");
        securityMonitor.performUpkeep();

        assertTrue(mockUDollarToken.paused(), "UDollarToken should be paused");
        assertTrue(mockUPool.paused(), "UPool should be paused");
    }

    function testSecurityIncidentCollateralRatio() public {
        mockUPool.setCollateralRatio(800000); // 80%, below the 90% threshold
        vm.warp(block.timestamp + CHECK_INTERVAL + 1);
        vm.prank(user);

        vm.expectEmit(true, false, false, true);
        emit SecurityIncident("Collateral ratio below threshold");
        securityMonitor.performUpkeep();

        assertTrue(mockUDollarToken.paused(), "UDollarToken should be paused");
        assertTrue(mockUPool.paused(), "UPool should be paused");
    }

    function testSetCheckIntervalUnauthorized() public {
        vm.prank(user);
        vm.expectRevert("SecurityMonitor: not authorized");
        securityMonitor.setCheckInterval(7200);
    }

    function testSetCheckIntervalAuthorized() public {
        uint256 newInterval = 7200;
        vm.prank(admin);
        securityMonitor.setCheckInterval(newInterval);
        assertEq(
            securityMonitor.getCheckInterval(),
            newInterval,
            "Check interval should be updated"
        );
    }

    // Define the events here for testing purposes
    event SecurityIncident(string message);
    event DefenderAlert(string message);
}
