// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {UbiquityPoolFacet} from "../../../../src/dollar/facets/UbiquityPoolFacet.sol";
import {MockChainLinkFeed} from "../../../../src/dollar/mocks/MockChainLinkFeed.sol";
import {MockCurveStableSwapNG} from "../../../../src/dollar/mocks/MockCurveStableSwapNG.sol";

contract PoolFacetHandler is Test {
    MockChainLinkFeed collateralTokenPriceFeed;
    UbiquityPoolFacet ubiquityPoolFacet;
    address admin;
    address user;
    MockCurveStableSwapNG curveDollarPlainPool;

    event MintSuccess(uint256 dollarAmount);
    event MintFailed(bytes reason);

    constructor(
        MockChainLinkFeed _collateralTokenPriceFeed,
        UbiquityPoolFacet _ubiquityPoolFacet,
        address _admin,
        address _user,
        MockCurveStableSwapNG _curveDollarPlainPool
    ) {
        collateralTokenPriceFeed = _collateralTokenPriceFeed;
        ubiquityPoolFacet = _ubiquityPoolFacet;
        admin = _admin;
        user = _user;
        curveDollarPlainPool = _curveDollarPlainPool;
    }

    // Dollar price manipulations
    //========================
    function setDollarPriceAboveThreshold() public {
        vm.prank(admin);
        curveDollarPlainPool.updateMockParams(1.02e18);
    }

    function setDollarPriceBelowThreshold() public {
        vm.prank(admin);
        curveDollarPlainPool.updateMockParams(0.98e18);
    }

    // Redeem manipulations
    //========================
    function setMintAndRedeemFees(uint256 mintFee, uint256 redeemFee) public {
        vm.prank(admin);
        ubiquityPoolFacet.setFees(0, mintFee, redeemFee);
    }

    function setRedemptionDelay(uint256 delay) public {
        vm.prank(admin);
        ubiquityPoolFacet.setRedemptionDelayBlocks(delay);
    }

    function collectRedemption() public {
        ubiquityPoolFacet.collectRedemption(0);
    }

    function redeemDollar(
        uint256 _dollarAmount,
        uint256 _governanceOutMin,
        uint256 _collateralOutMin
    ) public {
        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(
            0,
            _dollarAmount,
            _governanceOutMin,
            _collateralOutMin
        );
    }

    // Ceiling manipulations
    //========================
    function setPoolCeiling(uint256 newCeiling) public {
        vm.prank(admin);
        ubiquityPoolFacet.setPoolCeiling(0, newCeiling);
    }

    // Collateral manipulations
    //========================
    function updateCollateralRatio(uint256 newRatio) public {
        vm.prank(admin);
        ubiquityPoolFacet.setCollateralRatio(newRatio);
    }

    function mintUbiquityDollars(
        uint256 _dollarAmount,
        uint256 _dollarOutMin,
        uint256 _maxCollateralIn,
        uint256 _maxGovernanceIn,
        bool _isOneToOne
    ) public {
        vm.prank(user);

        uint256 dollarPrice = ubiquityPoolFacet.getDollarPriceUsd();
        console.log("::::::: DOLLAR PRICE:", dollarPrice);

        try
            ubiquityPoolFacet.mintDollar(
                0,
                _dollarAmount,
                _dollarOutMin,
                _maxCollateralIn,
                _maxGovernanceIn,
                _isOneToOne
            )
        {
            emit MintSuccess(_dollarAmount);
        } catch (bytes memory reason) {
            emit MintFailed(reason);
        }
    }
}
