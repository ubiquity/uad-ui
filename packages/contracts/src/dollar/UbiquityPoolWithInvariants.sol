// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;

import {LibUbiquityPool} from "./libraries/LibUbiquityPool.sol";
import {AppStorage, LibAppStorage} from "./libraries/LibAppStorage.sol";
import {IERC20Ubiquity} from "./interfaces/IERC20Ubiquity.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract UbiquityPoolWithInvariants {
    using SafeMath for uint256;

    function mintDollar(
        uint256 _collateralIndex,
        uint256 _dollarAmount,
        uint256 _dollarOutMin,
        uint256 _maxCollateralIn,
        uint256 _maxGovernanceIn,
        bool _isOneToOne
    )
        public
        returns (
            uint256 totalDollarMint,
            uint256 collateralNeeded,
            uint256 governanceNeeded
        )
    {
        (totalDollarMint, collateralNeeded, governanceNeeded) = LibUbiquityPool
            .mintDollar(
                _collateralIndex,
                _dollarAmount,
                _dollarOutMin,
                _maxCollateralIn,
                _maxGovernanceIn,
                _isOneToOne
            );

        (
            uint256 totalDollarSupplyInUsd,
            uint256 collateralUsdBalance
        ) = getDollarSupplyAndCollateralBalance();

        assert(totalDollarSupplyInUsd <= collateralUsdBalance);
    }

    function redeemDollar(
        uint256 _collateralIndex,
        uint256 _dollarAmount,
        uint256 _governanceOutMin,
        uint256 _collateralOutMin
    ) public returns (uint256 collateralOut, uint256 governanceOut) {
        (collateralOut, governanceOut) = LibUbiquityPool.redeemDollar(
            _collateralIndex,
            _dollarAmount,
            _governanceOutMin,
            _collateralOutMin
        );

        (
            uint256 totalDollarSupplyInUsd,
            uint256 collateralUsdBalance
        ) = getDollarSupplyAndCollateralBalance();

        assert(collateralUsdBalance >= totalDollarSupplyInUsd);
    }

    function getDollarSupplyAndCollateralBalance()
        public
        view
        returns (uint256 totalDollarSupplyInUsd, uint256 collateralUsdBalance)
    {
        uint256 totalDollarSupply = IERC20Ubiquity(
            LibAppStorage.appStorage().dollarTokenAddress
        ).totalSupply();

        collateralUsdBalance = LibUbiquityPool.collateralUsdBalance();

        require(collateralUsdBalance > 0, "Collateral balance is zero");
        require(totalDollarSupply > 0, "Dollar supply is zero");

        uint256 dollarPrice = LibUbiquityPool.getDollarPriceUsd();
        totalDollarSupplyInUsd = totalDollarSupply.mul(dollarPrice).div(1e6);
    }
}
