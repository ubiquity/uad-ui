// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../../../src/dollar/monitors/PoolLiquidityMonitor.sol";
import "../../helpers/LocalTestHelper.sol";
import {DiamondTestSetup} from "../../../test/diamond/DiamondTestSetup.sol";
import {DEFAULT_ADMIN_ROLE} from "../../../src/dollar/libraries/Constants.sol";

contract PoolLiquidityMonitorTest is DiamondTestSetup {
    PoolLiquidityMonitor monitor;
    address defenderRelayer = address(0x456);
    address unauthorized = address(0x123);

    function setUp() public override {
        super.setUp();
    }

    function testUnauthorizedCheckLiquidity() public {
        vm.prank(unauthorized);
        vm.expectRevert("Not authorized: Only Defender Relayer allowed");

        poolLiquidityMonitor.checkLiquidityVertex();
    }

    function testUnauthorizedSetDefenderRelayer() public {
        address newRelayer = address(0x789);

        vm.expectRevert("Manager: Caller is not admin");
        poolLiquidityMonitor.setDefenderRelayer(newRelayer);
    }

    function testSetDefenderRelayer() public {
        address newRelayer = address(0x789);

        vm.prank(admin);
        poolLiquidityMonitor.setDefenderRelayer(newRelayer);
    }

    function testSetThresholdPercentage() public {
        uint256 newThresholdPercentage = 30;

        vm.prank(admin);
        poolLiquidityMonitor.setThresholdPercentage(newThresholdPercentage);
    }

    function testDropLiquidityVertex() public {
        vm.expectRevert("Insufficient liquidity");

        vm.prank(admin);
        poolLiquidityMonitor.dropLiquidityVertex();
    }
}
