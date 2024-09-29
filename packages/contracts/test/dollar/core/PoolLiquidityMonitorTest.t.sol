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

contract PoolLiquidityMonitorTest is DiamondTestSetup {
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

        // enable collateral at index 0
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

    function testDropLiquidityVertex() public {
        uint256 currentCollateralLiquidity = ubiquityPoolFacet
            .collateralUsdBalance();

        vm.expectEmit(true, true, true, false);
        emit LiquidityVertexDropped(currentCollateralLiquidity);

        vm.prank(admin);
        monitor.dropLiquidityVertex();
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

    function testCheckLiquidity() public {
        vm.prank(user);
        ubiquityPoolFacet.mintDollar(1, 1e18, 0.9e18, 1e18, 0, true);

        uint256 currentCollateralLiquidity = ubiquityPoolFacet
            .collateralUsdBalance();

        vm.expectEmit(true, true, true, false);
        emit LiquidityVertexUpdated(currentCollateralLiquidity);

        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();
    }

    function testUnauthorizedCheckLiquidity() public {
        vm.prank(unauthorized);
        vm.expectRevert("Ubiquity Pool Security Monitor: not defender relayer");

        monitor.checkLiquidityVertex();
    }

    function testMonitorPausedEventEmittedAfterLiquidityDropBelowThreshold()
        public
    {
        curveDollarPlainPool.updateMockParams(0.99e18);

        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(0, 1e18, 0, 0);

        uint256 currentCollateralLiquidity = ubiquityPoolFacet
            .collateralUsdBalance();

        vm.expectEmit(true, true, true, false);
        emit MonitorPaused(currentCollateralLiquidity, 32);

        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();
    }

    function testMonitorPausedRevertAfterLiquidityDropBelowThreshold() public {
        curveDollarPlainPool.updateMockParams(0.99e18);

        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(0, 1e18, 0, 0);

        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();

        vm.expectRevert("Monitor paused");
        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();
    }

    function testMonitorAndDollarPauseAfterLiquidityDropBelowThreshold()
        public
    {
        curveDollarPlainPool.updateMockParams(0.99e18);

        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(0, 1e18, 0, 0);

        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();

        vm.expectRevert("Invalid collateral");
        ubiquityPoolFacet.collateralInformation(address(collateralToken));

        bool monitorPaused = monitor.monitorPaused();

        assertTrue(
            monitorPaused,
            "Monitor should be paused after liquidity drop"
        );

        ERC20Ubiquity dollarToken = ERC20Ubiquity(
            managerFacet.dollarTokenAddress()
        );
        bool dollarIsPaused = dollarToken.paused();

        assertTrue(
            dollarIsPaused,
            "Dollar should be paused after liquidity drop"
        );
    }

    function testLiquidityDropDoesNotPauseMonitorBelowThreshold() public {
        curveDollarPlainPool.updateMockParams(0.99e18);

        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(0, 1e17, 0, 0);

        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();

        ubiquityPoolFacet.collateralInformation(address(collateralToken));

        bool monitorPaused = monitor.monitorPaused();

        assertFalse(
            monitorPaused,
            "Monitor should Not be paused after liquidity drop"
        );
    }

    function testLiquidityDropPausesMonitorWhenCollateralToggledAfterThreshold()
        public
    {
        curveDollarPlainPool.updateMockParams(0.99e18);

        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(0, 1e18, 0, 0);

        vm.prank(admin);
        ubiquityPoolFacet.toggleCollateral(0);

        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();

        bool monitorPaused = monitor.monitorPaused();

        assertTrue(
            monitorPaused,
            "Monitor should be paused after liquidity drop, and any prior manipulation of collateral does not interfere with the ongoing incident management process."
        );

        address[] memory allCollaterals = ubiquityPoolFacet.allCollaterals();
        for (uint256 i = 0; i < allCollaterals.length; i++) {
            vm.expectRevert("Invalid collateral");

            vm.prank(user);
            ubiquityPoolFacet.collateralInformation(allCollaterals[i]);
        }
    }

    function testLiquidityDropDoesNotPauseMonitorWhenCollateralToggled()
        public
    {
        curveDollarPlainPool.updateMockParams(0.99e18);

        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(0, 1e17, 0, 0);

        vm.prank(admin);
        ubiquityPoolFacet.toggleCollateral(0);

        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();

        bool monitorPaused = monitor.monitorPaused();

        assertFalse(
            monitorPaused,
            "Monitor should Not be paused after liquidity drop, and any prior manipulation of collateral does not affect it"
        );
    }

    function testCheckLiquidityRevertsWhenMonitorIsPaused() public {
        vm.expectEmit(true, true, true, false);
        emit PausedToggled(true);

        vm.prank(admin);
        monitor.togglePaused();

        vm.expectRevert("Monitor paused");

        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();
    }

    function testMintDollarRevertsWhenCollateralDisabledDueToLiquidityDrop()
        public
    {
        curveDollarPlainPool.updateMockParams(0.99e18);

        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(0, 1e18, 0, 0);

        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();

        uint256 collateralCount = 3;
        for (uint256 i = 0; i < collateralCount; i++) {
            vm.expectRevert("Collateral disabled");

            vm.prank(user);
            ubiquityPoolFacet.mintDollar(i, 1e18, 0.9e18, 1e18, 0, true);
        }
    }

    function testRedeemDollarRevertsWhenCollateralDisabledDueToLiquidityDrop()
        public
    {
        curveDollarPlainPool.updateMockParams(0.99e18);

        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(0, 1e18, 0, 0);

        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();

        vm.expectRevert("Collateral disabled");
        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(1, 1e18, 0, 0);
    }

    function testDollarTokenRevertsOnTransferWhenPausedDueToLiquidityDrop()
        public
    {
        curveDollarPlainPool.updateMockParams(0.99e18);

        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(0, 1e18, 0, 0);

        vm.prank(defenderRelayer);
        monitor.checkLiquidityVertex();

        bool isPaused = dollarToken.paused();
        assertTrue(
            isPaused,
            "Expected the Dollar token to be paused after the liquidity drop"
        );

        ERC20Ubiquity dollarToken = ERC20Ubiquity(
            managerFacet.dollarTokenAddress()
        );

        vm.expectRevert("Pausable: paused");
        vm.prank(user);
        dollarToken.transfer(address(0x123), 1e18);
    }
}
