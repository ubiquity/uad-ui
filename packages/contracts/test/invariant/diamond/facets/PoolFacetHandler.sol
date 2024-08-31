// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {UbiquityPoolFacet} from "../../../../src/dollar/facets/UbiquityPoolFacet.sol";
import {MockChainLinkFeed} from "../../../../src/dollar/mocks/MockChainLinkFeed.sol";
import {MockCurveStableSwapNG} from "../../../../src/dollar/mocks/MockCurveStableSwapNG.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PoolFacetHandler is Test {
    using SafeMath for uint256;

    MockChainLinkFeed collateralTokenPriceFeed;
    UbiquityPoolFacet ubiquityPoolFacet;
    address admin;
    address user;
    MockCurveStableSwapNG curveDollarPlainPool;

    event MintSuccess(uint256 dollarAmount);
    event MintFailed(bytes reason);

    event redeemSuccess(uint256 dollarAmount);
    event redeemFailed(bytes reason);

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
    function setDollarPriceAboveThreshold(uint256 newDollarPrice) public {
        vm.assume(newDollarPrice > 1e18 && newDollarPrice < 2e18);

        vm.prank(admin);
        curveDollarPlainPool.updateMockParams(newDollarPrice);

        uint256 reductionFactor = newDollarPrice.sub(1e18).div(1e16);
        uint256 newCollateralRatio = uint256(1e6).sub(reductionFactor);

        ubiquityPoolFacet.setCollateralRatio(newCollateralRatio);
    }

    function setDollarPriceBelowThreshold(uint256 newDollarPrice) public {
        vm.assume(newDollarPrice >= 0.5e18 && newDollarPrice < 1e18);

        vm.prank(admin);
        curveDollarPlainPool.updateMockParams(newDollarPrice);

        uint256 increaseFactor = uint256(1e18).sub(newDollarPrice).div(1e16);
        uint256 newCollateralRatio = uint256(1e6).add(increaseFactor);

        ubiquityPoolFacet.setCollateralRatio(newCollateralRatio);
    }

    // Redeem manipulations
    //========================
    function setRedemptionDelay(uint256 delay) public {
        vm.prank(admin);
        ubiquityPoolFacet.setRedemptionDelayBlocks(delay);
    }

    function setMintAndRedeemFees(uint256 mintFee, uint256 redeemFee) public {
        vm.assume(mintFee >= 100000 && mintFee <= 200000);
        vm.assume(redeemFee >= 100000 && redeemFee <= 200000);

        vm.prank(admin);
        ubiquityPoolFacet.setFees(0, mintFee, redeemFee);
    }

    function collectRedemption() public {
        ubiquityPoolFacet.collectRedemption(0);
    }

    function redeemDollar(
        uint256 _dollarAmount,
        uint256 _governanceOutMin,
        uint256 _collateralOutMin
    ) public {
        vm.assume(_dollarAmount > 0 && _dollarAmount < type(uint256).max / 2);
        vm.assume(_governanceOutMin >= 0 && _governanceOutMin <= _dollarAmount);
        vm.assume(_collateralOutMin >= 0 && _collateralOutMin <= _dollarAmount);

        vm.prank(user);
        try
            ubiquityPoolFacet.redeemDollar(
                0,
                _dollarAmount,
                _governanceOutMin,
                _collateralOutMin
            )
        {
            emit redeemSuccess(_dollarAmount);
        } catch (bytes memory reason) {
            emit redeemFailed(reason);
        }
    }

    // Ceiling manipulations
    //========================
    function setPoolCeiling(uint256 newCeiling) public {
        vm.prank(admin);
        ubiquityPoolFacet.setPoolCeiling(0, newCeiling);
    }

    // Collateral price manipulations
    //========================
    function updateCollateralPrice(int256 _newPrice) public {
        vm.assume(_newPrice >= 50_000_000 && _newPrice <= 200_000_000);

        collateralTokenPriceFeed.updateMockParams(
            1, // round id
            _newPrice, // new price (8 decimals)
            block.timestamp, // started at
            block.timestamp, // updated at
            1 // answered in round
        );

        ubiquityPoolFacet.updateChainLinkCollateralPrice(0);

        uint256 newCollateralRatio = uint256(1e6 * 1e8).div(uint256(_newPrice));
        ubiquityPoolFacet.setCollateralRatio(newCollateralRatio);
    }

    function mintUbiquityDollars(
        uint256 _dollarAmount,
        uint256 _dollarOutMin,
        uint256 _maxCollateralIn,
        uint256 _maxGovernanceIn,
        bool _isOneToOne
    ) public {
        vm.assume(_dollarAmount > 0 && _dollarAmount < type(uint256).max / 2);
        vm.assume(_dollarOutMin <= _dollarAmount);
        vm.assume(
            _maxCollateralIn > 0 && _maxCollateralIn < type(uint256).max / 2
        );
        vm.assume(
            _maxGovernanceIn >= 0 && _maxGovernanceIn < type(uint256).max / 2
        );

        vm.prank(user);
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
