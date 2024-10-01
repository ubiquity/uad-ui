// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../../../src/dollar/core/UbiquityPoolSecurityMonitor.sol";
import "../../helpers/LocalTestHelper.sol";
import {DiamondTestSetup} from "../../../test/diamond/DiamondTestSetup.sol";
import {DEFAULT_ADMIN_ROLE, PAUSER_ROLE} from "../../../src/dollar/libraries/Constants.sol";
import {MockChainLinkFeed} from "../../../src/dollar/mocks/MockChainLinkFeed.sol";
import {MockERC20} from "../../../src/dollar/mocks/MockERC20.sol";
import {MockCurveStableSwapNG} from "../../../src/dollar/mocks/MockCurveStableSwapNG.sol";
import {MockCurveTwocryptoOptimized} from "../../../src/dollar/mocks/MockCurveTwocryptoOptimized.sol";
import {ERC20Ubiquity} from "../../../src/dollar/core/ERC20Ubiquity.sol";

contract UbiquityPoolSecurityMonitorTest is DiamondTestSetup {
    UbiquityPoolSecurityMonitor monitor;
    address defenderRelayer = address(0x456);
    address unauthorized = address(0x123);
    address newManagerFacet = address(0x457);
    address newUbiquityPoolFacet = address(0x458);
    address newAccessControlFacet = address(0x459);

    MockERC20 collateralToken;
    MockERC20 collateralToken2;
    MockERC20 collateralToken3;

    MockERC20 stableToken;
    MockERC20 wethToken;

    // mock three ChainLink price feeds, one for each token
    MockChainLinkFeed collateralTokenPriceFeed;
    MockChainLinkFeed ethUsdPriceFeed;
    MockChainLinkFeed stableUsdPriceFeed;

    // mock two curve pools Stablecoin/Dollar and Governance/WETH
    MockCurveStableSwapNG curveDollarPlainPool;
    MockCurveTwocryptoOptimized curveGovernanceEthPool;

    address user = address(1);

    event MonitorPaused(uint256 collateralLiquidity, uint256 diffPercentage);
    event LiquidityVertexDropped(uint256 liquidityVertex);
    event PausedToggled(bool paused);
    event LiquidityVertexUpdated(uint256 collateralLiquidity);

    function setUp() public override {
        super.setUp();

        vm.startPrank(admin);

        collateralToken = new MockERC20("COLLATERAL", "CLT", 18);
        collateralToken2 = new MockERC20("COLLATERAL-2", "CLT", 18);
        collateralToken3 = new MockERC20("COLLATERAL-3", "CLT", 18);

        wethToken = new MockERC20("WETH", "WETH", 18);
        stableToken = new MockERC20("STABLE", "STABLE", 18);

        collateralTokenPriceFeed = new MockChainLinkFeed();
        ethUsdPriceFeed = new MockChainLinkFeed();
        stableUsdPriceFeed = new MockChainLinkFeed();

        curveDollarPlainPool = new MockCurveStableSwapNG(
            address(stableToken),
            address(dollarToken)
        );

        curveGovernanceEthPool = new MockCurveTwocryptoOptimized(
            address(governanceToken),
            address(wethToken)
        );

        // add collateral token to the pool
        uint256 poolCeiling = 50_000e18; // max 50_000 of collateral tokens is allowed
        ubiquityPoolFacet.addCollateralToken(
            address(collateralToken),
            address(collateralTokenPriceFeed),
            poolCeiling
        );
        ubiquityPoolFacet.addCollateralToken(
            address(collateralToken2),
            address(collateralTokenPriceFeed),
            poolCeiling
        );
        ubiquityPoolFacet.addCollateralToken(
            address(collateralToken3),
            address(collateralTokenPriceFeed),
            poolCeiling
        );

        // set collateral price initial feed mock params
        collateralTokenPriceFeed.updateMockParams(
            1, // round id
            100_000_000, // answer, 100_000_000 = $1.00 (chainlink 8 decimals answer is converted to 6 decimals pool price)
            block.timestamp, // started at
            block.timestamp, // updated at
            1 // answered in round
        );

        // set ETH/USD price initial feed mock params
        ethUsdPriceFeed.updateMockParams(
            1, // round id
            2000_00000000, // answer, 2000_00000000 = $2000 (8 decimals)
            block.timestamp, // started at
            block.timestamp, // updated at
            1 // answered in round
        );

        // set stable/USD price feed initial mock params
        stableUsdPriceFeed.updateMockParams(
            1, // round id
            100_000_000, // answer, 100_000_000 = $1.00 (8 decimals)
            block.timestamp, // started at
            block.timestamp, // updated at
            1 // answered in round
        );

        // set ETH/Governance initial price to 20k in Curve pool mock (20k GOV == 1 ETH)
        curveGovernanceEthPool.updateMockParams(20_000e18);

        curveDollarPlainPool.updateMockParams(1.01e18);

        // set price feed for collateral token
        ubiquityPoolFacet.setCollateralChainLinkPriceFeed(
            address(collateralToken), // collateral token address
            address(collateralTokenPriceFeed), // price feed address
            1 days // price feed staleness threshold in seconds
        );
        ubiquityPoolFacet.setCollateralChainLinkPriceFeed(
            address(collateralToken2), // collateral token address
            address(collateralTokenPriceFeed), // price feed address
            1 days // price feed staleness threshold in seconds
        );
        ubiquityPoolFacet.setCollateralChainLinkPriceFeed(
            address(collateralToken3), // collateral token address
            address(collateralTokenPriceFeed), // price feed address
            1 days // price feed staleness threshold in seconds
        );

        // set price feed for ETH/USD pair
        ubiquityPoolFacet.setEthUsdChainLinkPriceFeed(
            address(ethUsdPriceFeed), // price feed address
            1 days // price feed staleness threshold in seconds
        );

        // set price feed for stable/USD pair
        ubiquityPoolFacet.setStableUsdChainLinkPriceFeed(
            address(stableUsdPriceFeed), // price feed address
            1 days // price feed staleness threshold in seconds
        );

        // enable collateral at index 0,1,2
        ubiquityPoolFacet.toggleCollateral(0);
        ubiquityPoolFacet.toggleCollateral(1);
        ubiquityPoolFacet.toggleCollateral(2);

        // set mint and redeem initial fees
        ubiquityPoolFacet.setFees(
            0, // collateral index
            10000, // 1% mint fee
            20000 // 2% redeem fee
        );
        // set redemption delay to 2 blocks
        ubiquityPoolFacet.setRedemptionDelayBlocks(2);
        // set mint price threshold to $1.01 and redeem price to $0.99
        ubiquityPoolFacet.setPriceThresholds(1010000, 990000);
        // set collateral ratio to 100%
        ubiquityPoolFacet.setCollateralRatio(1_000_000);
        // set Governance-ETH pool
        ubiquityPoolFacet.setGovernanceEthPoolAddress(
            address(curveGovernanceEthPool)
        );

        // set Curve plain pool in manager facet
        managerFacet.setStableSwapPlainPoolAddress(
            address(curveDollarPlainPool)
        );

        accessControlFacet.grantRole(DEFENDER_RELAYER_ROLE, defenderRelayer);

        // Initialize the UbiquityPoolSecurityMonitor contract
        monitor = new UbiquityPoolSecurityMonitor();
        monitor.initialize(
            address(accessControlFacet),
            address(ubiquityPoolFacet),
            address(managerFacet)
        );

        accessControlFacet.grantRole(DEFAULT_ADMIN_ROLE, address(monitor));
        accessControlFacet.grantRole(PAUSER_ROLE, address(monitor));

        // stop being admin
        vm.stopPrank();

        // mint 2000 Governance tokens to the user
        deal(address(governanceToken), user, 2000e18);
        // mint 2000 collateral tokens to the user
        collateralToken.mint(address(user), 2000e18);
        collateralToken2.mint(address(user), 2000e18);
        collateralToken3.mint(address(user), 2000e18);

        vm.startPrank(user);
        // user approves the pool to transfer collaterals
        collateralToken.approve(address(ubiquityPoolFacet), 100e18);
        collateralToken2.approve(address(ubiquityPoolFacet), 100e18);
        collateralToken3.approve(address(ubiquityPoolFacet), 100e18);

        ubiquityPoolFacet.mintDollar(0, 1e18, 0.9e18, 1e18, 0, true);
        ubiquityPoolFacet.mintDollar(1, 1e18, 0.9e18, 1e18, 0, true);
        ubiquityPoolFacet.mintDollar(2, 1e18, 0.9e18, 1e18, 0, true);

        vm.stopPrank();

        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();
    }

    function testSetManagerFacet() public {
        vm.prank(admin);
        monitor.setManagerFacet(newManagerFacet);
    }

    function testUnauthorizedSetManagerFacet() public {
        vm.expectRevert("Ubiquity Pool Security Monitor: not admin");
        monitor.setManagerFacet(newManagerFacet);
    }

    function testSetUbiquityPoolFacet() public {
        vm.prank(admin);
        monitor.setUbiquityPoolFacet(newUbiquityPoolFacet);
    }

    function testUnauthorizedSetUbiquityPoolFacet() public {
        vm.expectRevert("Ubiquity Pool Security Monitor: not admin");
        monitor.setUbiquityPoolFacet(newUbiquityPoolFacet);
    }

    function testSetAccessControlFacet() public {
        vm.prank(admin);
        monitor.setAccessControlFacet(newAccessControlFacet);
    }

    function testUnauthorizedSetAccessControlFacet() public {
        vm.expectRevert("Ubiquity Pool Security Monitor: not admin");
        monitor.setAccessControlFacet(newAccessControlFacet);
    }

    function testSetThresholdPercentage() public {
        uint256 newThresholdPercentage = 20;

        vm.prank(admin);
        monitor.setThresholdPercentage(newThresholdPercentage);
    }

    function testUnauthorizedSetThresholdPercentage() public {
        uint256 newThresholdPercentage = 30;

        vm.expectRevert("Ubiquity Pool Security Monitor: not admin");
        monitor.setThresholdPercentage(newThresholdPercentage);
    }

    /**
     * @notice Tests the dropLiquidityVertex function and ensures the correct event is emitted.
     * @dev Simulates a call from an account with the DEFAULT_ADMIN_ROLE to drop the liquidity vertex.
     *      Verifies that the current collateral liquidity is set as the new liquidity vertex and the
     *      LiquidityVertexDropped event is emitted with the correct value.
     */
    function testDropLiquidityVertex() public {
        // Get the current collateral liquidity from the UbiquityPoolFacet
        uint256 currentCollateralLiquidity = ubiquityPoolFacet
            .collateralUsdBalance();

        // Expect the LiquidityVertexDropped event to be emitted with the current collateral liquidity
        vm.expectEmit(true, true, true, false);
        emit LiquidityVertexDropped(currentCollateralLiquidity);

        // Simulate the admin account calling the dropLiquidityVertex function
        vm.prank(admin);
        monitor.dropLiquidityVertex();
        // The LiquidityVertexDropped event should be emitted with the correct liquidity value
    }

    function testUnauthorizedDropLiquidityVertex() public {
        vm.expectRevert("Ubiquity Pool Security Monitor: not admin");
        monitor.dropLiquidityVertex();
    }

    function testTogglePaused() public {
        vm.expectEmit(true, true, true, false);
        emit PausedToggled(true);

        vm.prank(admin);
        monitor.togglePaused();
    }

    function testUnauthorizedTogglePaused() public {
        vm.expectRevert("Ubiquity Pool Security Monitor: not admin");
        monitor.togglePaused();
    }

    /**
     * @notice Tests the update of liquidity vertex after the collateral liquidity is increased via minting.
     * @dev Simulates a user increasing liquidity by calling mintDollar and then checks if the liquidity vertex
     *      is updated correctly when the defender relayer calls checkLiquidityVertex.
     */
    function testCheckLiquidity() public {
        // Simulate the user minting dollars to increase the collateral liquidity
        vm.prank(user);
        ubiquityPoolFacet.mintDollar(1, 1e18, 0.9e18, 1e18, 0, true);

        // Fetch the updated collateral liquidity after minting
        uint256 currentCollateralLiquidity = ubiquityPoolFacet
            .collateralUsdBalance();

        // Expect the LiquidityVertexUpdated event to be emitted with the new liquidity value
        vm.expectEmit(true, true, true, false);
        emit LiquidityVertexUpdated(currentCollateralLiquidity);

        // Simulate the defender relayer calling checkLiquidityVertex to update the liquidity vertex
        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();
    }

    function testUnauthorizedCheckLiquidity() public {
        vm.prank(unauthorized);
        vm.expectRevert("Ubiquity Pool Security Monitor: not defender relayer");

        monitor.checkLiquidityVertex();
    }

    /**
     * @notice Tests that the `MonitorPaused` event is emitted when the liquidity drops below the configured threshold.
     * @dev Simulates a scenario where the collateral liquidity drops below the threshold by redeeming dollars,
     *      and checks if the monitor pauses and emits the `MonitorPaused` event.
     */
    function testMonitorPausedEventEmittedAfterLiquidityDropBelowThreshold()
        public
    {
        curveDollarPlainPool.updateMockParams(0.99e18);

        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(0, 1e18, 0, 0);

        // Fetch the current collateral liquidity after redemption
        uint256 currentCollateralLiquidity = ubiquityPoolFacet
            .collateralUsdBalance();

        // Expect the MonitorPaused event to be emitted with the current liquidity and percentage drop
        vm.expectEmit(true, true, true, false);
        emit MonitorPaused(currentCollateralLiquidity, 32); // 32 represents the percentage difference

        // Simulate the defender relayer calling checkLiquidityVertex to trigger the liquidity check
        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();
    }

    /**
     * @notice Tests that the `checkLiquidityVertex` function reverts with "Monitor paused" after the monitor is paused due to liquidity dropping below the threshold.
     * @dev Simulates a drop in collateral liquidity by redeeming dollars and ensures that once the liquidity drop exceeds the threshold,
     *      the monitor is paused and subsequent calls to `checkLiquidityVertex` revert with the message "Monitor paused".
     */
    function testMonitorPausedRevertAfterLiquidityDropBelowThreshold() public {
        curveDollarPlainPool.updateMockParams(0.99e18);

        // Simulate a user redeeming dollars, leading to a decrease in collateral liquidity
        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(0, 1e18, 0, 0);

        // Simulate the defender relayer calling checkLiquidityVertex to trigger the monitor pause
        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();

        // Expect a revert with "Monitor paused" message when trying to check liquidity again
        vm.expectRevert("Monitor paused");
        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();
    }

    /**
     * @notice Tests that both the monitor and the Ubiquity Dollar are paused after a liquidity drop below the threshold.
     * @dev Simulates a collateral price drop and ensures that:
     *      - The monitor is paused after the liquidity drop.
     *      - The collateral information is no longer valid and reverts with "Invalid collateral".
     *      - The Ubiquity Dollar token is paused after the liquidity drop.
     */
    function testMonitorAndDollarPauseAfterLiquidityDropBelowThreshold()
        public
    {
        curveDollarPlainPool.updateMockParams(0.99e18);

        // Simulate a user redeeming dollars, leading to a decrease in collateral liquidity
        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(0, 1e18, 0, 0);

        // Simulate the defender relayer calling checkLiquidityVertex to trigger the monitor pause
        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();

        // Expect a revert with "Invalid collateral" when trying to retrieve collateral information
        vm.expectRevert("Invalid collateral");
        ubiquityPoolFacet.collateralInformation(address(collateralToken));

        // Assert that the monitor is paused
        bool monitorPaused = monitor.monitorPaused();
        assertTrue(
            monitorPaused,
            "Monitor should be paused after liquidity drop"
        );

        // Assert that the Ubiquity Dollar token is paused
        ERC20Ubiquity dollarToken = ERC20Ubiquity(
            managerFacet.dollarTokenAddress()
        );
        bool dollarIsPaused = dollarToken.paused();
        assertTrue(
            dollarIsPaused,
            "Dollar should be paused after liquidity drop"
        );
    }

    /**
     * @notice Tests that the monitor is not paused when the liquidity drop does not exceed the configured threshold.
     * @dev Simulates a small collateral liquidity drop by redeeming dollars and ensures that:
     *      - The monitor does not pause if the liquidity drop remains above the threshold.
     *      - Collateral information remains valid and accessible after the liquidity drop.
     */
    function testLiquidityDropDoesNotPauseMonitor() public {
        curveDollarPlainPool.updateMockParams(0.99e18);

        // Simulate a user redeeming a small amount of dollars, causing a minor decrease in collateral liquidity
        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(0, 1e17, 0, 0);

        // Simulate the defender relayer calling checkLiquidityVertex to verify the monitor status
        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();

        // Ensure collateral information remains valid after the minor liquidity drop
        ubiquityPoolFacet.collateralInformation(address(collateralToken));

        // Assert that the monitor is not paused after the liquidity drop
        bool monitorPaused = monitor.monitorPaused();
        assertFalse(
            monitorPaused,
            "Monitor should Not be paused after liquidity drop"
        );
    }

    /**
     * @notice Tests that the monitor is paused after a significant liquidity drop, even when collateral was toggled before.
     * @dev Simulates a scenario where collateral liquidity drops below the threshold and collateral is toggled prior to the incident.
     *      Ensures that:
     *      - The monitor pauses after the liquidity drop.
     *      - Any collateral that was toggled prior to the liquidity check does not interfere with the monitor's behavior.
     *      - Collateral information becomes inaccessible after the monitor is paused.
     */
    function testLiquidityDropPausesMonitorWhenCollateralToggled() public {
        curveDollarPlainPool.updateMockParams(0.99e18);

        // Simulate a user redeeming dollars, causing a significant liquidity drop
        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(0, 1e18, 0, 0);

        // Simulate the admin toggling the collateral state
        vm.prank(admin);
        ubiquityPoolFacet.toggleCollateral(0);

        // Simulate the defender relayer calling checkLiquidityVertex to trigger the monitor pause
        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();

        // Assert that the monitor is paused after the liquidity drop
        bool monitorPaused = monitor.monitorPaused();
        assertTrue(
            monitorPaused,
            "Monitor should be paused after liquidity drop, and any prior manipulation of collateral does not interfere with the ongoing incident management process."
        );

        // Ensure that collateral information is inaccessible after the monitor is paused
        address[] memory allCollaterals = ubiquityPoolFacet.allCollaterals();
        for (uint256 i = 0; i < allCollaterals.length; i++) {
            vm.expectRevert("Invalid collateral");

            // Simulate the user trying to access collateral information, expecting a revert
            vm.prank(user);
            ubiquityPoolFacet.collateralInformation(allCollaterals[i]);
        }
    }

    /**
     * @notice Tests that the monitor is not paused when the liquidity drop does not exceed the threshold, even if collateral is toggled.
     * @dev Simulates a scenario where collateral liquidity drops but not enough to trigger the monitor pause.
     *      Ensures that:
     *      - The monitor remains active after a minor liquidity drop.
     *      - Any collateral that was toggled prior to the liquidity check does not affect the monitor’s behavior.
     */
    function testLiquidityDropDoesNotPauseMonitorWhenCollateralToggled()
        public
    {
        curveDollarPlainPool.updateMockParams(0.99e18);

        // Simulate a user redeeming a small amount of dollars, causing a minor liquidity drop
        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(0, 1e17, 0, 0);

        // Simulate the admin toggling the collateral state
        vm.prank(admin);
        ubiquityPoolFacet.toggleCollateral(0);

        // Simulate the defender relayer calling checkLiquidityVertex to verify the monitor status
        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();

        // Assert that the monitor is not paused after the minor liquidity drop
        bool monitorPaused = monitor.monitorPaused();
        assertFalse(
            monitorPaused,
            "Monitor should Not be paused after liquidity drop, and any prior manipulation of collateral does not affect it"
        );
    }

    /**
     * @notice Tests that `checkLiquidityVertex` reverts with "Monitor paused" when the monitor is manually paused.
     * @dev Simulates pausing the monitor and ensures that any subsequent calls to `checkLiquidityVertex` revert with the appropriate error message.
     */
    function testCheckLiquidityRevertsWhenMonitorIsPaused() public {
        // Expect the PausedToggled event to be emitted when the monitor is paused
        vm.expectEmit(true, true, true, false);
        emit PausedToggled(true);

        // Simulate the admin manually pausing the monitor
        vm.prank(admin);
        monitor.togglePaused();

        // Expect a revert with "Monitor paused" when checkLiquidityVertex is called while the monitor is paused
        vm.expectRevert("Monitor paused");

        // Simulate the defender relayer attempting to check liquidity while the monitor is paused
        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();
    }

    /**
     * @notice Tests that the `mintDollar` function reverts with "Collateral disabled" due to a liquidity drop.
     * @dev Simulates a liquidity drop below the threshold and ensures that collateral is disabled, causing subsequent attempts to mint dollars to fail.
     */
    function testMintDollarRevertsWhenCollateralDisabledDueToLiquidityDrop()
        public
    {
        curveDollarPlainPool.updateMockParams(0.99e18);

        // Simulate a user redeeming dollars, causing a significant liquidity drop
        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(0, 1e18, 0, 0);

        // Simulate the defender relayer calling checkLiquidityVertex to trigger the monitor pause and disable collateral
        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();

        // Attempt to mint dollars for each collateral, expecting a revert with "Collateral disabled"
        uint256 collateralCount = 3;
        for (uint256 i = 0; i < collateralCount; i++) {
            vm.expectRevert("Collateral disabled");

            vm.prank(user);
            ubiquityPoolFacet.mintDollar(i, 1e18, 0.9e18, 1e18, 0, true);
        }
    }

    /**
     * @notice Tests that the `redeemDollar` function reverts with "Collateral disabled" due to a liquidity drop.
     * @dev Simulates a liquidity drop below the threshold and ensures that collateral is disabled, causing subsequent attempts to redeem dollars to fail.
     */
    function testRedeemDollarRevertsWhenCollateralDisabledDueToLiquidityDrop()
        public
    {
        curveDollarPlainPool.updateMockParams(0.99e18);

        // Simulate a user redeeming dollars, causing a significant liquidity drop
        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(0, 1e18, 0, 0);

        // Simulate the defender relayer calling checkLiquidityVertex to trigger the monitor pause and disable collateral
        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();

        // Expect a revert with "Collateral disabled" when trying to redeem dollars after the collateral is disabled
        vm.expectRevert("Collateral disabled");

        // Simulate the user attempting to redeem dollars, which should revert due to disabled collateral
        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(1, 1e18, 0, 0);
    }

    /**
     * @notice Tests that the Ubiquity Dollar token reverts transfers with "Pausable: paused" when the token is paused due to a liquidity drop.
     * @dev Simulates a liquidity drop below the threshold and ensures that the Ubiquity Dollar token is paused, preventing transfers.
     */
    function testDollarTokenRevertsOnTransferWhenPausedDueToLiquidityDrop()
        public
    {
        curveDollarPlainPool.updateMockParams(0.99e18);

        // Simulate a user redeeming dollars, causing a significant liquidity drop
        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(0, 1e18, 0, 0);

        // Simulate the defender relayer calling checkLiquidityVertex to trigger the monitor pause and pause the dollar token
        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();

        // Assert that the Dollar token is paused after the liquidity drop
        bool isPaused = dollarToken.paused();
        assertTrue(
            isPaused,
            "Expected the Dollar token to be paused after the liquidity drop"
        );

        // Get the Ubiquity Dollar token contract
        ERC20Ubiquity dollarToken = ERC20Ubiquity(
            managerFacet.dollarTokenAddress()
        );

        // Expect a revert with "Pausable: paused" when trying to transfer the paused token
        vm.expectRevert("Pausable: paused");

        // Simulate the user attempting to transfer the paused dollar token, which should revert
        vm.prank(user);
        dollarToken.transfer(address(0x123), 1e18);
    }
}
