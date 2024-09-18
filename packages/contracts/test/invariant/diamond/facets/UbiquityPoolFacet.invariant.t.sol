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
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract UbiquityPoolFacetInvariantTest is DiamondTestSetup {
    using SafeMath for uint256;

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

        curveDollarPlainPool.updateMockParams(1.01e18);

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
            stableUsdPriceFeed,
            ethUsdPriceFeed,
            ubiquityPoolFacet,
            admin,
            user,
            curveDollarPlainPool,
            managerFacet,
            collateralToken
        );

        handler.mintUbiquityDollars(1e18, 0.9e18, 1e18, 0, true);

        targetContract(address(handler));
    }

    /**
     * @notice Ensures that the total supply of Ubiquity Dollars does not exceed the collateral value backing them.
     * @dev This invariant checker calculates the total supply of Ubiquity Dollars in USD terms and compares it to the USD value of the collateral.
     * The invariant asserts that the value of minted dollars does not exceed the value of the collateral.
     * If the invariant is violated, it indicates that more Ubiquity Dollars have been minted than the available collateral can support.
     */
    function invariant_CannotMintMoreDollarsThanCollateral() public {
        (
            uint256 totalDollarSupplyInUsd,
            uint256 collateralUsdBalance
        ) = getDollarSupplyAndCollateralBalance();

        assertTrue(
            totalDollarSupplyInUsd <= collateralUsdBalance,
            "Minted dollars exceed collateral value"
        );
    }

    /**
     * @notice Ensures that users cannot redeem more collateral than the value of the Dollar tokens provided.
     * @dev This invariant checker calculates the total supply of Ubiquity Dollars in USD terms and compares it to the USD value of the collateral.
     * The invariant asserts that the value of collateral redeemed does not exceed the value of the Dollar tokens burned.
     * If the invariant is violated, it indicates that more collateral has been redeemed than the Ubiquity Dollars can support.
     */
    function invariant_CannotRedeemMoreCollateralThanDollarValue() public {
        (
            uint256 totalDollarSupplyInUsd,
            uint256 collateralUsdBalance
        ) = getDollarSupplyAndCollateralBalance();

        assertTrue(
            collateralUsdBalance >= totalDollarSupplyInUsd,
            "Redeemed collateral exceeds provided Dollar tokens"
        );
    }

    /**
     * @notice Helper function to get the USD value of total Dollar supply and the collateral USD balance.
     * @dev This function returns the current total supply of Ubiquity Dollars in USD and the USD value of the collateral.
     * @return totalDollarSupplyInUsd The total supply of Ubiquity Dollars in USD (18 decimals).
     * @return collateralUsdBalance The total USD value of collateral backing the Ubiquity Dollars (18 decimals).
     */
    function getDollarSupplyAndCollateralBalance()
        public
        view
        returns (uint256 totalDollarSupplyInUsd, uint256 collateralUsdBalance)
    {
        uint256 totalDollarSupply = IERC20Ubiquity(
            managerFacet.dollarTokenAddress()
        ).totalSupply();

        collateralUsdBalance = ubiquityPoolFacet.collateralUsdBalance();

        require(collateralUsdBalance > 0, "Collateral balance is zero");
        require(totalDollarSupply > 0, "Dollar supply is zero");

        uint256 dollarPrice = ubiquityPoolFacet.getDollarPriceUsd();
        totalDollarSupplyInUsd = totalDollarSupply.mul(dollarPrice).div(1e6);
    }
}
