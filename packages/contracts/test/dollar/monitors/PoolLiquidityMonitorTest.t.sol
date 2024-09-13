// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../../../src/dollar/monitors/PoolLiquidityMonitor.sol";
import "../../helpers/LocalTestHelper.sol";
import {DiamondTestSetup} from "../../../test/diamond/DiamondTestSetup.sol";

contract PoolLiquidityMonitorTest is DiamondTestSetup {
    PoolLiquidityMonitor monitor;
    address defenderRelayer = address(0x456);
    address unauthorized = address(0x123);

    function setUp() public override {
        super.setUp();

        monitor = new PoolLiquidityMonitor(
            address(ubiquityPoolFacet),
            defenderRelayer,
            30
        );
    }

    function testInitialSetup() public {
        assertEq(monitor.defenderRelayer(), defenderRelayer);
    }

    function testUnauthorizedCheckLiquidity() public {
        vm.prank(unauthorized);
        vm.expectRevert("Not authorized: Only Defender Relayer allowed");

        monitor.checkLiquidityVertex();
    }

    function testCheckLiquidity() public {
        uint256 mockedLiquidity = 10000;

        vm.mockCall(
            address(ubiquityPoolFacet),
            abi.encodeWithSelector(
                UbiquityPoolFacet.collateralUsdBalance.selector
            ),
            abi.encode(mockedLiquidity)
        );

        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();
    }

    function testSetDefenderRelayer() public {
        address newRelayer = address(0x789);

        vm.expectRevert("Manager: Caller is not admin");
        monitor.setDefenderRelayer(newRelayer);
    }

    function testCheckLiquidityWithDifferentValues() public {
        uint256 mockedLiquidityHigh = 10000;
        uint256 mockedLiquidityLow = 100;

        vm.mockCall(
            address(ubiquityPoolFacet),
            abi.encodeWithSelector(
                UbiquityPoolFacet.collateralUsdBalance.selector
            ),
            abi.encode(mockedLiquidityHigh)
        );

        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();

        vm.mockCall(
            address(ubiquityPoolFacet),
            abi.encodeWithSelector(
                UbiquityPoolFacet.collateralUsdBalance.selector
            ),
            abi.encode(mockedLiquidityLow)
        );

        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();
    }
}
