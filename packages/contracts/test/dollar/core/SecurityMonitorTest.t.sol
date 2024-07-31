pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../../../src/dollar/utils/SecurityMonitor.sol";

contract SecurityMonitorTest is Test {
    SecurityMonitor securityMonitor;
    event SecurityIncident(string message);

    address admin = address(this);

    function setUp() public {
        // Deploy the SecurityMonitor contract with this contract as the admin
        securityMonitor = new SecurityMonitor(admin, 30);

        // Ensure this contract has the DEFAULT_ADMIN_ROLE
        assertTrue(
            securityMonitor.hasRole(securityMonitor.DEFAULT_ADMIN_ROLE(), admin)
        );

        // Grant PAUSER_ROLE to this contract
        vm.prank(admin);
        securityMonitor.grantRole(securityMonitor.PAUSER_ROLE(), admin);

        // Ensure this contract has the PAUSER_ROLE
        assertTrue(
            securityMonitor.hasRole(securityMonitor.PAUSER_ROLE(), admin)
        );
    }

    function testPauseAllContracts() public {
        vm.expectEmit(true, true, true, true);
        emit SecurityIncident(
            "All contracts paused due to a security incident."
        );
        vm.prank(admin);
        securityMonitor.pauseAllContracts();
        assertEq(securityMonitor.lastCheckBlock(), block.number);
    }

    function testNotifyTeam() public {
        string memory incidentMessage = "Test incident";
        vm.expectEmit(true, true, true, true);
        emit SecurityIncident(incidentMessage);
        vm.prank(admin);
        securityMonitor.notifyTeam(incidentMessage);
    }

    function testCheckUpkeep() public {
        (bool upkeepNeeded, ) = securityMonitor.checkUpkeep("");
        assertFalse(upkeepNeeded);
    }

    function testPerformUpkeep() public {
        // First, check if upkeep is needed
        (bool upkeepNeeded, ) = securityMonitor.checkUpkeep("");

        if (upkeepNeeded) {
            // If upkeep is needed, expect the security incident event
            vm.expectEmit(true, true, true, true);
            emit SecurityIncident(
                "Security incident detected: Liquidity threshold breached. Contracts paused."
            );

            securityMonitor.performUpkeep("");

            assertEq(securityMonitor.lastCheckBlock(), block.number);
        } else {
            // If upkeep is not needed, we should not expect any events
            // Just perform the upkeep and check that lastCheckBlock is updated
            securityMonitor.performUpkeep("");
            assertEq(securityMonitor.lastCheckBlock(), block.number);
        }
    }
}
