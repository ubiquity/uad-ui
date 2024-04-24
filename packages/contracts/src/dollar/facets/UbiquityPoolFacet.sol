// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;

import {IUbiquityPool} from "../interfaces/IUbiquityPool.sol";
import {Modifiers} from "../libraries/LibAppStorage.sol";
import {LibUbiquityPool} from "../libraries/LibUbiquityPool.sol";

/**
 * @notice Ubiquity pool facet
 * @notice Allows users to:
 * - deposit collateral in exchange for Ubiquity Dollars
 * - redeem Ubiquity Dollars in exchange for the earlier provided collateral
 */
contract UbiquityPoolFacet is IUbiquityPool, Modifiers {
    //=====================
    // Views
    //=====================

    /// @inheritdoc IUbiquityPool
    function allCollaterals() external view returns (address[] memory) {
        return LibUbiquityPool.allCollaterals();
    }

    /// @inheritdoc IUbiquityPool
    function collateralInformation(
        address collateralAddress
    )
        external
        view
        returns (LibUbiquityPool.CollateralInformation memory returnData)
    {
        return LibUbiquityPool.collateralInformation(collateralAddress);
    }

    /// @inheritdoc IUbiquityPool
    function collateralRatio() external view returns (uint256) {
        return LibUbiquityPool.collateralRatio();
    }

    /// @inheritdoc IUbiquityPool
    function collateralUsdBalance()
        external
        view
        returns (uint256 balanceTally)
    {
        return LibUbiquityPool.collateralUsdBalance();
    }

    /// @inheritdoc IUbiquityPool
    function ethUsdPriceFeedInformation()
        external
        view
        returns (address, uint256)
    {
        return LibUbiquityPool.ethUsdPriceFeedInformation();
    }

    /// @inheritdoc IUbiquityPool
    function freeCollateralBalance(
        uint256 collateralIndex
    ) external view returns (uint256) {
        return LibUbiquityPool.freeCollateralBalance(collateralIndex);
    }

    /// @inheritdoc IUbiquityPool
    function getDollarInCollateral(
        uint256 collateralIndex,
        uint256 dollarAmount
    ) external view returns (uint256) {
        return
            LibUbiquityPool.getDollarInCollateral(
                collateralIndex,
                dollarAmount
            );
    }

    /// @inheritdoc IUbiquityPool
    function getDollarPriceUsd()
        external
        view
        returns (uint256 dollarPriceUsd)
    {
        return LibUbiquityPool.getDollarPriceUsd();
    }

    /// @inheritdoc IUbiquityPool
    function getGovernancePriceUsd()
        external
        view
        returns (uint256 governancePriceUsd)
    {
        return LibUbiquityPool.getGovernancePriceUsd();
    }

    /// @inheritdoc IUbiquityPool
    function getRedeemCollateralBalance(
        address userAddress,
        uint256 collateralIndex
    ) external view returns (uint256) {
        return
            LibUbiquityPool.getRedeemCollateralBalance(
                userAddress,
                collateralIndex
            );
    }

    /// @inheritdoc IUbiquityPool
    function getRedeemGovernanceBalance(
        address userAddress
    ) external view returns (uint256) {
        return LibUbiquityPool.getRedeemGovernanceBalance(userAddress);
    }

    /// @inheritdoc IUbiquityPool
    function governanceEthPoolAddress() external view returns (address) {
        return LibUbiquityPool.governanceEthPoolAddress();
    }

    /// @inheritdoc IUbiquityPool
    function stableUsdPriceFeedInformation()
        external
        view
        returns (address, uint256)
    {
        return LibUbiquityPool.stableUsdPriceFeedInformation();
    }

    //====================
    // Public functions
    //====================

    /// @inheritdoc IUbiquityPool
    function mintDollar(
        uint256 collateralIndex,
        uint256 dollarAmount,
        uint256 dollarOutMin,
        uint256 maxCollateralIn,
        uint256 maxGovernanceIn,
        bool isOneToOne
    )
        external
        nonReentrant
        returns (
            uint256 totalDollarMint,
            uint256 collateralNeeded,
            uint256 governanceNeeded
        )
    {
        return
            LibUbiquityPool.mintDollar(
                collateralIndex,
                dollarAmount,
                dollarOutMin,
                maxCollateralIn,
                maxGovernanceIn,
                isOneToOne
            );
    }

    /// @inheritdoc IUbiquityPool
    function redeemDollar(
        uint256 collateralIndex,
        uint256 dollarAmount,
        uint256 governanceOutMin,
        uint256 collateralOutMin
    )
        external
        nonReentrant
        returns (uint256 collateralOut, uint256 governanceOut)
    {
        return
            LibUbiquityPool.redeemDollar(
                collateralIndex,
                dollarAmount,
                governanceOutMin,
                collateralOutMin
            );
    }

    /// @inheritdoc IUbiquityPool
    function collectRedemption(
        uint256 collateralIndex
    )
        external
        nonReentrant
        returns (uint256 governanceAmount, uint256 collateralAmount)
    {
        return LibUbiquityPool.collectRedemption(collateralIndex);
    }

    /// @inheritdoc IUbiquityPool
    function updateChainLinkCollateralPrice(uint256 collateralIndex) external {
        LibUbiquityPool.updateChainLinkCollateralPrice(collateralIndex);
    }

    //=========================
    // AMO minters functions
    //=========================

    /// @inheritdoc IUbiquityPool
    function amoMinterBorrow(uint256 collateralAmount) external {
        LibUbiquityPool.amoMinterBorrow(collateralAmount);
    }

    //========================
    // Restricted functions
    //========================

    /// @inheritdoc IUbiquityPool
    function addAmoMinter(address amoMinterAddress) external onlyAdmin {
        LibUbiquityPool.addAmoMinter(amoMinterAddress);
    }

    /// @inheritdoc IUbiquityPool
    function addCollateralToken(
        address collateralAddress,
        address chainLinkPriceFeedAddress,
        uint256 poolCeiling
    ) external onlyAdmin {
        LibUbiquityPool.addCollateralToken(
            collateralAddress,
            chainLinkPriceFeedAddress,
            poolCeiling
        );
    }

    /// @inheritdoc IUbiquityPool
    function removeAmoMinter(address amoMinterAddress) external onlyAdmin {
        LibUbiquityPool.removeAmoMinter(amoMinterAddress);
    }

    /// @inheritdoc IUbiquityPool
    function setCollateralChainLinkPriceFeed(
        address collateralAddress,
        address chainLinkPriceFeedAddress,
        uint256 stalenessThreshold
    ) external onlyAdmin {
        LibUbiquityPool.setCollateralChainLinkPriceFeed(
            collateralAddress,
            chainLinkPriceFeedAddress,
            stalenessThreshold
        );
    }

    /// @inheritdoc IUbiquityPool
    function setCollateralRatio(uint256 newCollateralRatio) external onlyAdmin {
        LibUbiquityPool.setCollateralRatio(newCollateralRatio);
    }

    /// @inheritdoc IUbiquityPool
    function setEthUsdChainLinkPriceFeed(
        address newPriceFeedAddress,
        uint256 newStalenessThreshold
    ) external onlyAdmin {
        LibUbiquityPool.setEthUsdChainLinkPriceFeed(
            newPriceFeedAddress,
            newStalenessThreshold
        );
    }

    /// @inheritdoc IUbiquityPool
    function setFees(
        uint256 collateralIndex,
        uint256 newMintFee,
        uint256 newRedeemFee
    ) external onlyAdmin {
        LibUbiquityPool.setFees(collateralIndex, newMintFee, newRedeemFee);
    }

    /// @inheritdoc IUbiquityPool
    function setGovernanceEthPoolAddress(
        address newGovernanceEthPoolAddress
    ) external onlyAdmin {
        LibUbiquityPool.setGovernanceEthPoolAddress(
            newGovernanceEthPoolAddress
        );
    }

    /// @inheritdoc IUbiquityPool
    function setPoolCeiling(
        uint256 collateralIndex,
        uint256 newCeiling
    ) external onlyAdmin {
        LibUbiquityPool.setPoolCeiling(collateralIndex, newCeiling);
    }

    /// @inheritdoc IUbiquityPool
    function setPriceThresholds(
        uint256 newMintPriceThreshold,
        uint256 newRedeemPriceThreshold
    ) external onlyAdmin {
        LibUbiquityPool.setPriceThresholds(
            newMintPriceThreshold,
            newRedeemPriceThreshold
        );
    }

    /// @inheritdoc IUbiquityPool
    function setRedemptionDelayBlocks(
        uint256 newRedemptionDelayBlocks
    ) external onlyAdmin {
        LibUbiquityPool.setRedemptionDelayBlocks(newRedemptionDelayBlocks);
    }

    /// @inheritdoc IUbiquityPool
    function setStableUsdChainLinkPriceFeed(
        address newPriceFeedAddress,
        uint256 newStalenessThreshold
    ) external onlyAdmin {
        LibUbiquityPool.setStableUsdChainLinkPriceFeed(
            newPriceFeedAddress,
            newStalenessThreshold
        );
    }

    /// @inheritdoc IUbiquityPool
    function toggleCollateral(uint256 collateralIndex) external onlyAdmin {
        LibUbiquityPool.toggleCollateral(collateralIndex);
    }

    /// @inheritdoc IUbiquityPool
    function toggleMintRedeemBorrow(
        uint256 collateralIndex,
        uint8 toggleIndex
    ) external onlyAdmin {
        LibUbiquityPool.toggleMintRedeemBorrow(collateralIndex, toggleIndex);
    }
}
