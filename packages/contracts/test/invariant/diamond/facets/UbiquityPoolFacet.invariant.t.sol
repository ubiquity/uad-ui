// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {UbiquityPoolFacet} from "../../../../src/dollar/facets/UbiquityPoolFacet.sol";
import {LibUbiquityPool} from "../../../../src/dollar/libraries/LibUbiquityPool.sol";
import {MockERC20} from "../../../../src/dollar/mocks/MockERC20.sol";
import {DiamondTestSetup} from "../../../../test/diamond/DiamondTestSetup.sol";
import {MockChainLinkFeed} from "../../../../src/dollar/mocks/MockChainLinkFeed.sol";

contract UbiquityPoolFacetInvariantTest is DiamondTestSetup {
    MockERC20 public collateralToken;
    MockChainLinkFeed public collateralTokenPriceFeed;

    function setUp() public override {
        super.setUp();

        vm.startPrank(admin);

        collateralToken = new MockERC20("COLLATERAL", "CLT", 18);
        collateralTokenPriceFeed = new MockChainLinkFeed();

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

        // set price feed for collateral token
        ubiquityPoolFacet.setCollateralChainLinkPriceFeed(
            address(collateralToken), // collateral token address
            address(collateralTokenPriceFeed), // price feed address
            1 days // price feed staleness threshold in seconds
        );

        ubiquityPoolFacet.toggleCollateral(0);

        vm.stopPrank();
    }

    function invariant_CollateralTokenIsEnabledAndCorrectlyAdded() public {
        // Check if the collateral token is correctly added and enabled
        LibUbiquityPool.CollateralInformation
            memory collateralInfo = ubiquityPoolFacet.collateralInformation(
                address(collateralToken)
            );
        assertTrue(
            collateralInfo.isEnabled,
            "Collateral token should be enabled"
        );
        assertEq(
            collateralInfo.collateralAddress,
            address(collateralToken),
            "Collateral token address mismatch"
        );
        assertEq(
            collateralInfo.poolCeiling,
            50_000e18,
            "Collateral pool ceiling mismatch"
        );
    }

    function invariant_CollateralPriceFeedIsSetCorrectly() public {
        // Check if the price feed for the collateral token is set correctly
        LibUbiquityPool.CollateralInformation
            memory collateralInfo = ubiquityPoolFacet.collateralInformation(
                address(collateralToken)
            );
        assertEq(
            collateralInfo.collateralPriceFeedAddress,
            address(collateralTokenPriceFeed),
            "Collateral price feed address mismatch"
        );
        assertEq(
            collateralInfo.collateralPriceFeedStalenessThreshold,
            1 days,
            "Collateral price feed staleness threshold mismatch"
        );
    }
}
