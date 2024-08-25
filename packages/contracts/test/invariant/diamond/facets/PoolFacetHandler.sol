// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {UbiquityPoolFacet} from "../../../../src/dollar/facets/UbiquityPoolFacet.sol";
import {MockChainLinkFeed} from "../../../../src/dollar/mocks/MockChainLinkFeed.sol";

contract PoolFacetHandler is Test {
    MockChainLinkFeed collateralTokenPriceFeed;
    UbiquityPoolFacet ubiquityPoolFacet;

    constructor(
        MockChainLinkFeed _collateralTokenPriceFeed,
        UbiquityPoolFacet _ubiquityPoolFacet
    ) {
        collateralTokenPriceFeed = _collateralTokenPriceFeed;
        ubiquityPoolFacet = _ubiquityPoolFacet;
    }

    function setCollateralRatio(uint256 newRatio) public {
        ubiquityPoolFacet.setCollateralRatio(newRatio);
    }

    function updateCollateralPrice(uint256 newPrice) public {
        uint256 timestamp = block.timestamp;

        collateralTokenPriceFeed.updateMockParams(
            1,
            int256(newPrice),
            timestamp,
            timestamp,
            1
        );

        ubiquityPoolFacet.updateChainLinkCollateralPrice(0);
    }

    function mintUbiquityDollars(
        uint256 dollarAmount,
        uint256 dollarOutMin,
        uint256 maxCollateralIn,
        uint256 maxGovernanceIn,
        bool isOneToOne
    ) public {
        ubiquityPoolFacet.mintDollar(
            0,
            dollarAmount,
            dollarOutMin,
            maxCollateralIn,
            maxGovernanceIn,
            isOneToOne
        );
    }
}
