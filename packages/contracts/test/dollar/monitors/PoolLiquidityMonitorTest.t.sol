// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../../../src/dollar/monitors/PoolLiquidityMonitor.sol";
import "../../helpers/LocalTestHelper.sol";

contract PoolLiquidityMonitorTest is LocalTestHelper {
    PoolLiquidityMonitor monitor;
    address defenderRelayer = address(0x456);

    function setUp() public override {
        super.setUp();

        monitor = new PoolLiquidityMonitor(
            address(ubiquityPoolFacet),
            defenderRelayer
        );
    }

    function testInitialSetup() public {
        assertEq(monitor.defenderRelayer(), defenderRelayer);
    }

    function testSetDefenderRelayer() public {
        address newRelayer = address(0x789);

        monitor.setDefenderRelayer(newRelayer);

        assertEq(monitor.defenderRelayer(), newRelayer);
    }
}
