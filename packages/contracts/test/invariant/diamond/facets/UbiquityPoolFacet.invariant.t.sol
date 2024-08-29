// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {UbiquityPoolFacet} from "../../../../src/dollar/facets/UbiquityPoolFacet.sol";
import {LibUbiquityPool} from "../../../../src/dollar/libraries/LibUbiquityPool.sol";
import {MockERC20} from "../../../../src/dollar/mocks/MockERC20.sol";
import {DiamondTestSetup} from "../../../../test/diamond/DiamondTestSetup.sol";
import {MockChainLinkFeed} from "../../../../src/dollar/mocks/MockChainLinkFeed.sol";
import {PoolFacetHandler} from "./PoolFacetHandler.sol";
import {IERC20Ubiquity} from "../../../../src/dollar/interfaces/IERC20Ubiquity.sol";
import {MockCurveStableSwapNG} from "../../../../src/dollar/mocks/MockCurveStableSwapNG.sol";
import {MockCurveTwocryptoOptimized} from "../../../../src/dollar/mocks/MockCurveTwocryptoOptimized.sol";

contract UbiquityPoolFacetInvariantTest is DiamondTestSetup {
    PoolFacetHandler handler;

    // mock three tokens: collateral token, stable token, wrapped ETH token
    MockERC20 collateralToken;
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

    function setUp() public override {
        super.setUp();

        vm.startPrank(admin);

        collateralToken = new MockERC20("COLLATERAL", "CLT", 18);
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

        // set price feed for collateral token
        ubiquityPoolFacet.setCollateralChainLinkPriceFeed(
            address(collateralToken), // collateral token address
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

        // stop being admin
        vm.stopPrank();

        // mint 2000 Governance tokens to the user
        deal(address(governanceToken), user, 2000e18);
        // mint 2000 collateral tokens to the user
        collateralToken.mint(address(user), 2000e18);
        // user approves the pool to transfer collateral
        vm.prank(user);
        collateralToken.approve(address(ubiquityPoolFacet), 100e18);

        handler = new PoolFacetHandler(
            collateralTokenPriceFeed,
            ubiquityPoolFacet,
            admin,
            user,
            curveDollarPlainPool
        );
        targetContract(address(handler));
    }

    function invariant_CannotMintMoreDollarsThanCollateral() public {
        uint256 totalDollarSupply = IERC20Ubiquity(
            managerFacet.dollarTokenAddress()
        ).totalSupply();

        uint256 collateralUsdBalance = ubiquityPoolFacet.collateralUsdBalance();
        console.log(
            ":::::::| UbiquityPoolFacetInvariantTest | collateralUsdBalance:",
            collateralUsdBalance
        );

        vm.assume(collateralUsdBalance > 0 && totalDollarSupply > 0);

        uint256 dollarPrice = ubiquityPoolFacet.getDollarPriceUsd();
        uint256 totalDollarSupplyInUsd = (totalDollarSupply * dollarPrice) /
            1e6;

        console.log(
            ":::::::| UbiquityPoolFacetInvariantTest | dollarPrice:",
            dollarPrice
        );
        console.log(
            ":::::::| UbiquityPoolFacetInvariantTest | totalDollarSupply:",
            totalDollarSupply
        );
        console.log(
            ":::::::| UbiquityPoolFacetInvariantTest | totalDollarSupplyInUsd:",
            totalDollarSupplyInUsd
        );

        assertTrue(
            totalDollarSupplyInUsd <= collateralUsdBalance,
            "Minted dollars exceed collateral value"
        );
    }
}
