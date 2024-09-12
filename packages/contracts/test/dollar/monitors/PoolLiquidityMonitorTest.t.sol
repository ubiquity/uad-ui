// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../../../src/dollar/monitors/PoolLiquidityMonitor.sol";
import "../../helpers/LocalTestHelper.sol";

contract PoolLiquidityMonitorTest is LocalTestHelper {
    PoolLiquidityMonitor monitor;
    address defenderRelayer = address(0x456);
    address unauthorized = address(0x123);

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

        vm.prank(monitor.owner());
        monitor.setDefenderRelayer(newRelayer);

        assertEq(monitor.defenderRelayer(), newRelayer);
    }

    function testUnauthorizedCheckLiquidity() public {
        vm.prank(unauthorized);
        vm.expectRevert("Not authorized: Only Defender Relayer allowed");

        monitor.checkLiquidity();
    }

    function testCheckLiquidity() public {
        vm.prank(defenderRelayer);
        monitor.checkLiquidity();
    }

    function testSetDefenderRelayerToZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert();
        monitor.setDefenderRelayer(address(0));
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
        monitor.checkLiquidity();

        vm.mockCall(
            address(ubiquityPoolFacet),
            abi.encodeWithSelector(
                UbiquityPoolFacet.collateralUsdBalance.selector
            ),
            abi.encode(mockedLiquidityLow)
        );

        vm.prank(defenderRelayer);
        monitor.checkLiquidity();
    }
}
