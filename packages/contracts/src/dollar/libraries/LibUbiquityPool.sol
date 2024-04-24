// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/interfaces/AggregatorV3Interface.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {ICurveStableSwapNG} from "../interfaces/ICurveStableSwapNG.sol";
import {ICurveTwocryptoOptimized} from "../interfaces/ICurveTwocryptoOptimized.sol";
import {IDollarAmoMinter} from "../interfaces/IDollarAmoMinter.sol";
import {IERC20Ubiquity} from "../interfaces/IERC20Ubiquity.sol";
import {UBIQUITY_POOL_PRICE_PRECISION} from "./Constants.sol";
import {AppStorage, LibAppStorage} from "./LibAppStorage.sol";

/**
 * @notice Ubiquity pool library
 * @notice Allows users to:
 * - deposit collateral in exchange for Ubiquity Dollars
 * - redeem Ubiquity Dollars in exchange for the earlier provided collateral
 */
library LibUbiquityPool {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /// @notice Storage slot used to store data for this library
    bytes32 constant UBIQUITY_POOL_STORAGE_POSITION =
        bytes32(
            uint256(keccak256("ubiquity.contracts.ubiquity.pool.storage")) - 1
        ) & ~bytes32(uint256(0xff));

    /// @notice Struct used as a storage for this library
    struct UbiquityPoolStorage {
        //========
        // Core
        //========
        // minter address -> is it enabled
        mapping(address amoMinter => bool isEnabled) isAmoMinterEnabled;
        //======================
        // Collateral related
        //======================
        // available collateral tokens
        address[] collateralAddresses;
        // collateral address -> collateral index
        mapping(address collateralAddress => uint256 collateralIndex) collateralIndex;
        // collateral index -> chainlink price feed addresses
        address[] collateralPriceFeedAddresses;
        // collateral index -> threshold in seconds when chainlink answer should be considered stale
        uint256[] collateralPriceFeedStalenessThresholds;
        // collateral index -> collateral price
        uint256[] collateralPrices;
        // how much collateral/governance tokens user should provide/get to mint/redeem Dollar tokens, 1e6 precision
        uint256 collateralRatio;
        // array collateral symbols
        string[] collateralSymbols;
        // collateral address -> is it enabled
        mapping(address collateralAddress => bool isEnabled) isCollateralEnabled;
        // Number of decimals needed to get to E18. collateral index -> missing decimals
        uint256[] missingDecimals;
        // Total across all collaterals. Accounts for missing_decimals
        uint256[] poolCeilings;
        //====================
        // Redeem related
        //====================
        // user -> block number (collateral independent)
        mapping(address => uint256) lastRedeemedBlock;
        // 1010000 = $1.01
        uint256 mintPriceThreshold;
        // 990000 = $0.99
        uint256 redeemPriceThreshold;
        // address -> collateral index -> balance
        mapping(address user => mapping(uint256 collateralIndex => uint256 amount)) redeemCollateralBalances;
        // address -> balance
        mapping(address user => uint256 amount) redeemGovernanceBalances;
        // number of blocks to wait before being able to collectRedemption()
        uint256 redemptionDelayBlocks;
        // collateral index -> balance
        uint256[] unclaimedPoolCollateral;
        // total amount of unclaimed Governance tokens in the pool
        uint256 unclaimedPoolGovernance;
        //================
        // Fees related
        //================
        // minting fee of a particular collateral index, 1_000_000 = 100%
        uint256[] mintingFee;
        // redemption fee of a particular collateral index, 1_000_000 = 100%
        uint256[] redemptionFee;
        //=================
        // Pause related
        //=================
        // whether borrowing collateral by AMO minters is paused for a particular collateral index
        bool[] isBorrowPaused;
        // whether minting is paused for a particular collateral index
        bool[] isMintPaused;
        // whether redeeming is paused for a particular collateral index
        bool[] isRedeemPaused;
        //====================================
        // Governance token pricing related
        //====================================
        // chainlink price feed for ETH/USD pair
        address ethUsdPriceFeedAddress;
        // threshold in seconds when chainlink's ETH/USD price feed answer should be considered stale
        uint256 ethUsdPriceFeedStalenessThreshold;
        // Curve's CurveTwocryptoOptimized contract for Governance/ETH pair
        address governanceEthPoolAddress;
        //================================
        // Dollar token pricing related
        //================================
        // chainlink price feed for stable/USD pair
        address stableUsdPriceFeedAddress;
        // threshold in seconds when chainlink's stable/USD price feed answer should be considered stale
        uint256 stableUsdPriceFeedStalenessThreshold;
    }

    /// @notice Struct used for detailed collateral information
    struct CollateralInformation {
        uint256 index;
        string symbol;
        address collateralAddress;
        address collateralPriceFeedAddress;
        uint256 collateralPriceFeedStalenessThreshold;
        bool isEnabled;
        uint256 missingDecimals;
        uint256 price;
        uint256 poolCeiling;
        bool isMintPaused;
        bool isRedeemPaused;
        bool isBorrowPaused;
        uint256 mintingFee;
        uint256 redemptionFee;
    }

    /**
     * @notice Returns struct used as a storage for this library
     * @return uPoolStorage Struct used as a storage
     */
    function ubiquityPoolStorage()
        internal
        pure
        returns (UbiquityPoolStorage storage uPoolStorage)
    {
        bytes32 position = UBIQUITY_POOL_STORAGE_POSITION;
        assembly {
            uPoolStorage.slot := position
        }
    }

    //===========
    // Events
    //===========

    /// @notice Emitted when new AMO minter is added
    event AmoMinterAdded(address amoMinterAddress);
    /// @notice Emitted when AMO minter is removed
    event AmoMinterRemoved(address amoMinterAddress);
    /// @notice Emitted on setting a chainlink's collateral price feed params
    event CollateralPriceFeedSet(
        uint256 collateralIndex,
        address priceFeedAddress,
        uint256 stalenessThreshold
    );
    /// @notice Emitted on setting a collateral price
    event CollateralPriceSet(uint256 collateralIndex, uint256 newPrice);
    /// @notice Emitted on setting a collateral ratio
    event CollateralRatioSet(uint256 newCollateralRatio);
    /// @notice Emitted on enabling/disabling a particular collateral token
    event CollateralToggled(uint256 collateralIndex, bool newState);
    /// @notice Emitted on setting chainlink's price feed for ETH/USD pair
    event EthUsdPriceFeedSet(
        address newPriceFeedAddress,
        uint256 newStalenessThreshold
    );
    /// @notice Emitted when fees are updated
    event FeesSet(
        uint256 collateralIndex,
        uint256 newMintFee,
        uint256 newRedeemFee
    );
    /// @notice Emitted on setting a pool for Governance/ETH pair
    event GovernanceEthPoolSet(address newGovernanceEthPoolAddress);
    /// @notice Emitted on toggling pause for mint/redeem/borrow
    event MintRedeemBorrowToggled(uint256 collateralIndex, uint8 toggleIndex);
    /// @notice Emitted when new pool ceiling (i.e. max amount of collateral) is set
    event PoolCeilingSet(uint256 collateralIndex, uint256 newCeiling);
    /// @notice Emitted when mint and redeem price thresholds are updated (1_000_000 = $1.00)
    event PriceThresholdsSet(
        uint256 newMintPriceThreshold,
        uint256 newRedeemPriceThreshold
    );
    /// @notice Emitted when a new redemption delay in blocks is set
    event RedemptionDelayBlocksSet(uint256 redemptionDelayBlocks);
    /// @notice Emitted on setting chainlink's price feed for stable/USD pair
    event StableUsdPriceFeedSet(
        address newPriceFeedAddress,
        uint256 newStalenessThreshold
    );

    //=====================
    // Modifiers
    //=====================

    /**
     * @notice Checks whether collateral token is enabled (i.e. mintable and redeemable)
     * @param collateralIndex Collateral token index
     */
    modifier collateralEnabled(uint256 collateralIndex) {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();
        require(
            poolStorage.isCollateralEnabled[
                poolStorage.collateralAddresses[collateralIndex]
            ],
            "Collateral disabled"
        );
        _;
    }

    /**
     * @notice Checks whether a caller is the AMO minter address
     */
    modifier onlyAmoMinter() {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();
        require(
            poolStorage.isAmoMinterEnabled[msg.sender],
            "Not an AMO Minter"
        );
        _;
    }

    //=====================
    // Views
    //=====================

    /**
     * @notice Returns all collateral addresses
     * @return All collateral addresses
     */
    function allCollaterals() internal view returns (address[] memory) {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();
        return poolStorage.collateralAddresses;
    }

    /**
     * @notice Check if collateral token with given address already exists
     * @param collateralAddress The collateral token address to check
     */
    function collateralExists(
        address collateralAddress
    ) internal view returns (bool) {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();
        address[] memory collateralAddresses = poolStorage.collateralAddresses;

        for (uint256 i = 0; i < collateralAddresses.length; i++) {
            if (collateralAddresses[i] == collateralAddress) {
                return true;
            }
        }
        return false;
    }

    /**
     * @notice Returns collateral information
     * @param collateralAddress Address of the collateral token
     * @return returnData Collateral info
     */
    function collateralInformation(
        address collateralAddress
    ) internal view returns (CollateralInformation memory returnData) {
        // load the storage
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        // validation
        require(
            poolStorage.isCollateralEnabled[collateralAddress],
            "Invalid collateral"
        );

        // get the index
        uint256 index = poolStorage.collateralIndex[collateralAddress];

        returnData = CollateralInformation(
            index,
            poolStorage.collateralSymbols[index],
            collateralAddress,
            poolStorage.collateralPriceFeedAddresses[index],
            poolStorage.collateralPriceFeedStalenessThresholds[index],
            poolStorage.isCollateralEnabled[collateralAddress],
            poolStorage.missingDecimals[index],
            poolStorage.collateralPrices[index],
            poolStorage.poolCeilings[index],
            poolStorage.isMintPaused[index],
            poolStorage.isRedeemPaused[index],
            poolStorage.isBorrowPaused[index],
            poolStorage.mintingFee[index],
            poolStorage.redemptionFee[index]
        );
    }

    /**
     * @notice Returns current collateral ratio
     * @return Collateral ratio
     */
    function collateralRatio() internal view returns (uint256) {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();
        return poolStorage.collateralRatio;
    }

    /**
     * @notice Returns USD value of all collateral tokens held in the pool, in E18
     * @return balanceTally USD value of all collateral tokens
     */
    function collateralUsdBalance()
        internal
        view
        returns (uint256 balanceTally)
    {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();
        uint256 collateralTokensCount = poolStorage.collateralAddresses.length;
        balanceTally = 0;
        for (uint256 i = 0; i < collateralTokensCount; i++) {
            balanceTally += freeCollateralBalance(i)
                .mul(10 ** poolStorage.missingDecimals[i])
                .mul(poolStorage.collateralPrices[i])
                .div(UBIQUITY_POOL_PRICE_PRECISION);
        }
    }

    /**
     * @notice Returns chainlink price feed information for ETH/USD pair
     * @return Price feed address and staleness threshold in seconds
     */
    function ethUsdPriceFeedInformation()
        internal
        view
        returns (address, uint256)
    {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();
        return (
            poolStorage.ethUsdPriceFeedAddress,
            poolStorage.ethUsdPriceFeedStalenessThreshold
        );
    }

    /**
     * @notice Returns free collateral balance (i.e. that can be borrowed by AMO minters)
     * @param collateralIndex collateral token index
     * @return Amount of free collateral
     */
    function freeCollateralBalance(
        uint256 collateralIndex
    ) internal view returns (uint256) {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();
        return
            IERC20(poolStorage.collateralAddresses[collateralIndex])
                .balanceOf(address(this))
                .sub(poolStorage.unclaimedPoolCollateral[collateralIndex]);
    }

    /**
     * @notice Returns Dollar value in collateral tokens
     * @param collateralIndex collateral token index
     * @param dollarAmount Amount of Dollars
     * @return Value in collateral tokens
     */
    function getDollarInCollateral(
        uint256 collateralIndex,
        uint256 dollarAmount
    ) internal view returns (uint256) {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();
        return
            dollarAmount
                .mul(UBIQUITY_POOL_PRICE_PRECISION)
                .div(10 ** poolStorage.missingDecimals[collateralIndex])
                .div(poolStorage.collateralPrices[collateralIndex]);
    }

    /**
     * @notice Returns Ubiquity Dollar token USD price (1e6 precision) from Curve plain pool (Stable coin, Ubiquity Dollar)
     * How it works:
     * 1. Fetch Stable/USD quote from chainlink
     * 2. Fetch Dollar/Stable quote from Curve's plain pool
     * 3. Calculate Dollar token price in USD
     * @return dollarPriceUsd USD price of Ubiquity Dollar
     */
    function getDollarPriceUsd()
        internal
        view
        returns (uint256 dollarPriceUsd)
    {
        AppStorage storage store = LibAppStorage.appStorage();
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        // fetch Stable/USD quote from chainlink (8 decimals)
        AggregatorV3Interface stableUsdPriceFeed = AggregatorV3Interface(
            poolStorage.stableUsdPriceFeedAddress
        );
        (
            ,
            int256 stableUsdAnswer,
            ,
            uint256 stableUsdUpdatedAt,

        ) = stableUsdPriceFeed.latestRoundData();
        uint256 stableUsdPriceFeedDecimals = stableUsdPriceFeed.decimals();
        // validate Stable/USD chainlink response
        require(stableUsdAnswer > 0, "Invalid Stable/USD price");
        require(
            block.timestamp - stableUsdUpdatedAt <
                poolStorage.stableUsdPriceFeedStalenessThreshold,
            "Stale Stable/USD data"
        );

        // fetch Dollar/Stable quote from Curve's plain pool (18 decimals)
        uint256 dollarPriceUsdD18 = ICurveStableSwapNG(
            store.stableSwapPlainPoolAddress
        ).price_oracle(0);

        // convert to 6 decimals
        dollarPriceUsd = dollarPriceUsdD18
            .mul(UBIQUITY_POOL_PRICE_PRECISION)
            .mul(uint256(stableUsdAnswer))
            .div(10 ** stableUsdPriceFeedDecimals)
            .div(1e18);
    }

    /**
     * @notice Returns Governance token price in USD (6 decimals precision)
     * @dev How it works:
     * 1. Fetch ETH/USD price from chainlink oracle
     * 2. Fetch Governance/ETH price from Curve's oracle
     * 3. Calculate Governance token price in USD
     * @return governancePriceUsd Governance token price in USD
     */
    function getGovernancePriceUsd()
        internal
        view
        returns (uint256 governancePriceUsd)
    {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        // fetch latest ETH/USD price
        AggregatorV3Interface ethUsdPriceFeed = AggregatorV3Interface(
            poolStorage.ethUsdPriceFeedAddress
        );
        (, int256 answer, , uint256 updatedAt, ) = ethUsdPriceFeed
            .latestRoundData();
        uint256 ethUsdPriceFeedDecimals = ethUsdPriceFeed.decimals();

        // validate ETH/USD chainlink response
        require(answer > 0, "Invalid price");
        require(
            block.timestamp - updatedAt <
                poolStorage.ethUsdPriceFeedStalenessThreshold,
            "Stale data"
        );

        // convert ETH/USD chainlink price to 6 decimals
        uint256 ethUsdPrice = uint256(answer)
            .mul(UBIQUITY_POOL_PRICE_PRECISION)
            .div(10 ** ethUsdPriceFeedDecimals);

        // fetch ETH/Governance price (18 decimals)
        uint256 ethGovernancePriceD18 = ICurveTwocryptoOptimized(
            poolStorage.governanceEthPoolAddress
        ).price_oracle();
        // calculate Governance/ETH price (18 decimals)
        uint256 governanceEthPriceD18 = uint256(1e18).mul(1e18).div(
            ethGovernancePriceD18
        );

        // calculate Governance token price in USD (6 decimals)
        governancePriceUsd = governanceEthPriceD18.mul(ethUsdPrice).div(1e18);
    }

    /**
     * @notice Returns user's balance available for redemption
     * @param userAddress User address
     * @param collateralIndex Collateral token index
     * @return User's balance available for redemption
     */
    function getRedeemCollateralBalance(
        address userAddress,
        uint256 collateralIndex
    ) internal view returns (uint256) {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();
        return
            poolStorage.redeemCollateralBalances[userAddress][collateralIndex];
    }

    /**
     * @notice Returns user's Governance tokens balance available for redemption
     * @param userAddress User address
     * @return User's Governance tokens balance available for redemption
     */
    function getRedeemGovernanceBalance(
        address userAddress
    ) internal view returns (uint256) {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();
        return poolStorage.redeemGovernanceBalances[userAddress];
    }

    /**
     * @notice Returns pool address for Governance/ETH pair
     * @return Pool address
     */
    function governanceEthPoolAddress() internal view returns (address) {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();
        return poolStorage.governanceEthPoolAddress;
    }

    /**
     * @notice Returns chainlink price feed information for stable/USD pair
     * @dev Here stable coin refers to the 1st coin in the Curve's stable/Dollar plain pool
     * @return Price feed address and staleness threshold in seconds
     */
    function stableUsdPriceFeedInformation()
        internal
        view
        returns (address, uint256)
    {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();
        return (
            poolStorage.stableUsdPriceFeedAddress,
            poolStorage.stableUsdPriceFeedStalenessThreshold
        );
    }

    //====================
    // Public functions
    //====================

    /**
     * @notice Mints Dollars in exchange for collateral tokens
     * @param collateralIndex Collateral token index
     * @param dollarAmount Amount of dollars to mint
     * @param dollarOutMin Min amount of dollars to mint (slippage protection)
     * @param maxCollateralIn Max amount of collateral to send (slippage protection)
     * @param maxGovernanceIn Max amount of Governance tokens to send (slippage protection)
     * @param isOneToOne Force providing only collateral without Governance tokens
     * @return totalDollarMint Amount of Dollars minted
     * @return collateralNeeded Amount of collateral sent to the pool
     * @return governanceNeeded Amount of Governance tokens burnt from sender
     */
    function mintDollar(
        uint256 collateralIndex,
        uint256 dollarAmount,
        uint256 dollarOutMin,
        uint256 maxCollateralIn,
        uint256 maxGovernanceIn,
        bool isOneToOne
    )
        internal
        collateralEnabled(collateralIndex)
        returns (
            uint256 totalDollarMint,
            uint256 collateralNeeded,
            uint256 governanceNeeded
        )
    {
        require(
            ubiquityPoolStorage().isMintPaused[collateralIndex] == false,
            "Minting is paused"
        );
        // prevent unnecessary mints
        require(
            getDollarPriceUsd() >= ubiquityPoolStorage().mintPriceThreshold,
            "Dollar price too low"
        );

        // update collateral price
        updateChainLinkCollateralPrice(collateralIndex);

        // user forces 1-to-1 override or collateral ratio >= 100%
        if (
            isOneToOne ||
            ubiquityPoolStorage().collateralRatio >=
            UBIQUITY_POOL_PRICE_PRECISION
        ) {
            // get amount of collateral for minting Dollars
            collateralNeeded = getDollarInCollateral(
                collateralIndex,
                dollarAmount
            );
            governanceNeeded = 0;
        } else if (ubiquityPoolStorage().collateralRatio == 0) {
            // collateral ratio is 0%, Dollar tokens can be minted by providing only Governance tokens (i.e. fully algorithmic stablecoin)
            collateralNeeded = 0;
            governanceNeeded = dollarAmount
                .mul(UBIQUITY_POOL_PRICE_PRECISION)
                .div(getGovernancePriceUsd());
        } else {
            // fractional, user has to provide both collateral and Governance tokens
            uint256 dollarForCollateral = dollarAmount
                .mul(ubiquityPoolStorage().collateralRatio)
                .div(UBIQUITY_POOL_PRICE_PRECISION);
            uint256 dollarForGovernance = dollarAmount.sub(dollarForCollateral);
            collateralNeeded = getDollarInCollateral(
                collateralIndex,
                dollarForCollateral
            );
            governanceNeeded = dollarForGovernance
                .mul(UBIQUITY_POOL_PRICE_PRECISION)
                .div(getGovernancePriceUsd());
        }

        // subtract the minting fee
        totalDollarMint = dollarAmount
            .mul(
                UBIQUITY_POOL_PRICE_PRECISION.sub(
                    ubiquityPoolStorage().mintingFee[collateralIndex]
                )
            )
            .div(UBIQUITY_POOL_PRICE_PRECISION);

        // check slippages
        require((totalDollarMint >= dollarOutMin), "Dollar slippage");
        require((collateralNeeded <= maxCollateralIn), "Collateral slippage");
        require((governanceNeeded <= maxGovernanceIn), "Governance slippage");

        // check the pool ceiling
        require(
            freeCollateralBalance(collateralIndex).add(collateralNeeded) <=
                ubiquityPoolStorage().poolCeilings[collateralIndex],
            "Pool ceiling"
        );

        // burn Governance tokens from sender and send collateral to the pool
        IERC20Ubiquity(LibAppStorage.appStorage().governanceTokenAddress)
            .burnFrom(msg.sender, governanceNeeded);
        IERC20(ubiquityPoolStorage().collateralAddresses[collateralIndex])
            .safeTransferFrom(msg.sender, address(this), collateralNeeded);

        // mint Dollars
        IERC20Ubiquity(LibAppStorage.appStorage().dollarTokenAddress).mint(
            msg.sender,
            totalDollarMint
        );
    }

    /**
     * @notice Burns redeemable Ubiquity Dollars and sends back 1 USD of collateral token for every 1 Ubiquity Dollar burned
     * @dev Redeem process is split in two steps:
     * @dev 1. `redeemDollar()`
     * @dev 2. `collectRedemption()`
     * @dev This is done in order to prevent someone using a flash loan of a collateral token to mint, redeem, and collect in a single transaction/block
     * @param collateralIndex Collateral token index being withdrawn
     * @param dollarAmount Amount of Ubiquity Dollars being burned
     * @param governanceOutMin Minimum amount of Governance tokens that'll be withdrawn, used to set acceptable slippage
     * @param collateralOutMin Minimum amount of collateral tokens that'll be withdrawn, used to set acceptable slippage
     * @return collateralOut Amount of collateral tokens ready for redemption
     */
    function redeemDollar(
        uint256 collateralIndex,
        uint256 dollarAmount,
        uint256 governanceOutMin,
        uint256 collateralOutMin
    )
        internal
        collateralEnabled(collateralIndex)
        returns (uint256 collateralOut, uint256 governanceOut)
    {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        require(
            poolStorage.isRedeemPaused[collateralIndex] == false,
            "Redeeming is paused"
        );

        // prevent unnecessary redemptions that could adversely affect the Dollar price
        require(
            getDollarPriceUsd() <= poolStorage.redeemPriceThreshold,
            "Dollar price too high"
        );

        uint256 dollarAfterFee = dollarAmount
            .mul(
                UBIQUITY_POOL_PRICE_PRECISION.sub(
                    poolStorage.redemptionFee[collateralIndex]
                )
            )
            .div(UBIQUITY_POOL_PRICE_PRECISION);

        // update collateral price
        updateChainLinkCollateralPrice(collateralIndex);

        // get current collateral ratio
        uint256 currentCollateralRatio = poolStorage.collateralRatio;

        // fully collateralized
        if (currentCollateralRatio >= UBIQUITY_POOL_PRICE_PRECISION) {
            // get collateral output for incoming Dollars
            collateralOut = getDollarInCollateral(
                collateralIndex,
                dollarAfterFee
            );
            governanceOut = 0;
        } else if (currentCollateralRatio == 0) {
            // algorithmic, fully covered by Governance tokens
            collateralOut = 0;
            governanceOut = dollarAfterFee
                .mul(UBIQUITY_POOL_PRICE_PRECISION)
                .div(getGovernancePriceUsd());
        } else {
            // fractional, partially covered by collateral and Governance tokens
            collateralOut = getDollarInCollateral(
                collateralIndex,
                dollarAfterFee
            ).mul(currentCollateralRatio).div(UBIQUITY_POOL_PRICE_PRECISION);
            governanceOut = dollarAfterFee
                .mul(UBIQUITY_POOL_PRICE_PRECISION.sub(currentCollateralRatio))
                .div(getGovernancePriceUsd());
        }

        // checks
        require(
            collateralOut <=
                (IERC20(poolStorage.collateralAddresses[collateralIndex]))
                    .balanceOf(address(this))
                    .sub(poolStorage.unclaimedPoolCollateral[collateralIndex]),
            "Insufficient pool collateral"
        );
        require(collateralOut >= collateralOutMin, "Collateral slippage");
        require(governanceOut >= governanceOutMin, "Governance slippage");

        // increase collateral redemption balances
        poolStorage.redeemCollateralBalances[msg.sender][
            collateralIndex
        ] = poolStorage
        .redeemCollateralBalances[msg.sender][collateralIndex].add(
                collateralOut
            );
        poolStorage.unclaimedPoolCollateral[collateralIndex] = poolStorage
            .unclaimedPoolCollateral[collateralIndex]
            .add(collateralOut);

        // increase Governance redemption balances
        poolStorage.redeemGovernanceBalances[msg.sender] = poolStorage
            .redeemGovernanceBalances[msg.sender]
            .add(governanceOut);
        poolStorage.unclaimedPoolGovernance = poolStorage
            .unclaimedPoolGovernance
            .add(governanceOut);

        poolStorage.lastRedeemedBlock[msg.sender] = block.number;

        // burn Dollars
        IERC20Ubiquity(LibAppStorage.appStorage().dollarTokenAddress).burnFrom(
            msg.sender,
            dollarAmount
        );
        // mint Governance tokens to this address
        IERC20Ubiquity(LibAppStorage.appStorage().governanceTokenAddress).mint(
            address(this),
            governanceOut
        );
    }

    /**
     * @notice Used to collect collateral and Governance tokens after redeeming/burning Ubiquity Dollars
     * @dev Redeem process is split in two steps:
     * @dev 1. `redeemDollar()`
     * @dev 2. `collectRedemption()`
     * @dev This is done in order to prevent someone using a flash loan of a collateral token to mint, redeem, and collect in a single transaction/block
     * @param collateralIndex Collateral token index being collected
     * @return governanceAmount Amount of Governance tokens redeemed
     * @return collateralAmount Amount of collateral tokens redeemed
     */
    function collectRedemption(
        uint256 collateralIndex
    )
        internal
        collateralEnabled(collateralIndex)
        returns (uint256 governanceAmount, uint256 collateralAmount)
    {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        require(
            poolStorage.isRedeemPaused[collateralIndex] == false,
            "Redeeming is paused"
        );
        require(
            (
                poolStorage.lastRedeemedBlock[msg.sender].add(
                    poolStorage.redemptionDelayBlocks
                )
            ) < block.number,
            "Too soon to collect redemption"
        );

        bool sendGovernance = false;
        bool sendCollateral = false;

        if (poolStorage.redeemGovernanceBalances[msg.sender] > 0) {
            governanceAmount = poolStorage.redeemGovernanceBalances[msg.sender];
            poolStorage.redeemGovernanceBalances[msg.sender] = 0;
            poolStorage.unclaimedPoolGovernance = poolStorage
                .unclaimedPoolGovernance
                .sub(governanceAmount);
            sendGovernance = true;
        }

        if (
            poolStorage.redeemCollateralBalances[msg.sender][collateralIndex] >
            0
        ) {
            collateralAmount = poolStorage.redeemCollateralBalances[msg.sender][
                collateralIndex
            ];
            poolStorage.redeemCollateralBalances[msg.sender][
                collateralIndex
            ] = 0;
            poolStorage.unclaimedPoolCollateral[collateralIndex] = poolStorage
                .unclaimedPoolCollateral[collateralIndex]
                .sub(collateralAmount);
            sendCollateral = true;
        }

        // send out tokens
        if (sendGovernance) {
            IERC20(LibAppStorage.appStorage().governanceTokenAddress)
                .safeTransfer(msg.sender, governanceAmount);
        }
        if (sendCollateral) {
            IERC20(poolStorage.collateralAddresses[collateralIndex])
                .safeTransfer(msg.sender, collateralAmount);
        }
    }

    /**
     * @notice Updates collateral token price in USD from ChainLink price feed
     * @param collateralIndex Collateral token index
     */
    function updateChainLinkCollateralPrice(uint256 collateralIndex) internal {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            poolStorage.collateralPriceFeedAddresses[collateralIndex]
        );

        // fetch latest price
        (
            ,
            // roundId
            int256 answer, // startedAt
            ,
            uint256 updatedAt, // answeredInRound

        ) = priceFeed.latestRoundData();

        // fetch number of decimals in chainlink feed
        uint256 priceFeedDecimals = priceFeed.decimals();

        // validation
        require(answer > 0, "Invalid price");
        require(
            block.timestamp - updatedAt <
                poolStorage.collateralPriceFeedStalenessThresholds[
                    collateralIndex
                ],
            "Stale data"
        );

        // convert chainlink price to 6 decimals
        uint256 price = uint256(answer).mul(UBIQUITY_POOL_PRICE_PRECISION).div(
            10 ** priceFeedDecimals
        );

        poolStorage.collateralPrices[collateralIndex] = price;

        emit CollateralPriceSet(collateralIndex, price);
    }

    //=========================
    // AMO minters functions
    //=========================

    /**
     * @notice Allows AMO minters to borrow collateral to make yield in external
     * protocols like Compound, Curve, erc...
     * @dev Bypasses the gassy mint->redeem cycle for AMOs to borrow collateral
     * @param collateralAmount Amount of collateral to borrow
     */
    function amoMinterBorrow(uint256 collateralAmount) internal onlyAmoMinter {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        // checks the collateral index of the minter as an additional safety check
        uint256 minterCollateralIndex = IDollarAmoMinter(msg.sender)
            .collateralIndex();

        // checks to see if borrowing is paused
        require(
            poolStorage.isBorrowPaused[minterCollateralIndex] == false,
            "Borrowing is paused"
        );

        // ensure collateral is enabled
        require(
            poolStorage.isCollateralEnabled[
                poolStorage.collateralAddresses[minterCollateralIndex]
            ],
            "Collateral disabled"
        );

        // ensure the pool is solvent (i.e. AMO minter borrows less than users want to redeem)
        require(
            collateralAmount <= freeCollateralBalance(minterCollateralIndex),
            "Not enough free collateral"
        );

        // transfer
        IERC20(poolStorage.collateralAddresses[minterCollateralIndex])
            .safeTransfer(msg.sender, collateralAmount);
    }

    //========================
    // Restricted functions
    //========================

    /**
     * @notice Adds a new AMO minter
     * @param amoMinterAddress AMO minter address
     */
    function addAmoMinter(address amoMinterAddress) internal {
        require(amoMinterAddress != address(0), "Zero address detected");

        // make sure the AMO Minter has collateralDollarBalance()
        uint256 collatValE18 = IDollarAmoMinter(amoMinterAddress)
            .collateralDollarBalance();
        require(collatValE18 >= 0, "Invalid AMO");

        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        poolStorage.isAmoMinterEnabled[amoMinterAddress] = true;

        emit AmoMinterAdded(amoMinterAddress);
    }

    /**
     * @notice Adds a new collateral token
     * @param collateralAddress Collateral token address
     * @param chainLinkPriceFeedAddress Chainlink's price feed address
     * @param poolCeiling Max amount of available tokens for collateral
     */
    function addCollateralToken(
        address collateralAddress,
        address chainLinkPriceFeedAddress,
        uint256 poolCeiling
    ) internal {
        require(
            !collateralExists(collateralAddress),
            "Collateral already added"
        );

        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        uint256 collateralIndex = poolStorage.collateralAddresses.length;

        // add collateral address to all collaterals
        poolStorage.collateralAddresses.push(collateralAddress);

        // for fast collateral address -> collateral idx lookups later
        poolStorage.collateralIndex[collateralAddress] = collateralIndex;

        // set collateral initially to disabled
        poolStorage.isCollateralEnabled[collateralAddress] = false;

        // add in the missing decimals
        poolStorage.missingDecimals.push(
            uint256(18).sub(ERC20(collateralAddress).decimals())
        );

        // add in the collateral symbols
        poolStorage.collateralSymbols.push(ERC20(collateralAddress).symbol());

        // initialize unclaimed pool collateral
        poolStorage.unclaimedPoolCollateral.push(0);

        // initialize paused prices to $1 as a backup
        poolStorage.collateralPrices.push(UBIQUITY_POOL_PRICE_PRECISION);

        // set fees to 0 by default
        poolStorage.mintingFee.push(0);
        poolStorage.redemptionFee.push(0);

        // handle the pauses
        poolStorage.isMintPaused.push(false);
        poolStorage.isRedeemPaused.push(false);
        poolStorage.isBorrowPaused.push(false);

        // set pool ceiling
        poolStorage.poolCeilings.push(poolCeiling);

        // set price feed address
        poolStorage.collateralPriceFeedAddresses.push(
            chainLinkPriceFeedAddress
        );

        // set price feed staleness threshold in seconds
        poolStorage.collateralPriceFeedStalenessThresholds.push(1 days);
    }

    /**
     * @notice Removes AMO minter
     * @param amoMinterAddress AMO minter address to remove
     */
    function removeAmoMinter(address amoMinterAddress) internal {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        poolStorage.isAmoMinterEnabled[amoMinterAddress] = false;

        emit AmoMinterRemoved(amoMinterAddress);
    }

    /**
     * @notice Sets collateral ChainLink price feed params
     * @param collateralAddress Collateral token address
     * @param chainLinkPriceFeedAddress ChainLink price feed address
     * @param stalenessThreshold Threshold in seconds when chainlink answer should be considered stale
     */
    function setCollateralChainLinkPriceFeed(
        address collateralAddress,
        address chainLinkPriceFeedAddress,
        uint256 stalenessThreshold
    ) internal {
        require(
            collateralExists(collateralAddress),
            "Collateral does not exist"
        );

        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        uint256 collateralIndex = poolStorage.collateralIndex[
            collateralAddress
        ];

        // set price feed address
        poolStorage.collateralPriceFeedAddresses[
            collateralIndex
        ] = chainLinkPriceFeedAddress;

        // set staleness threshold in seconds when chainlink answer should be considered stale
        poolStorage.collateralPriceFeedStalenessThresholds[
            collateralIndex
        ] = stalenessThreshold;

        emit CollateralPriceFeedSet(
            collateralIndex,
            chainLinkPriceFeedAddress,
            stalenessThreshold
        );
    }

    /**
     * @notice Sets collateral ratio
     * @dev How much collateral/governance tokens user should provide/get to mint/redeem Dollar tokens, 1e6 precision.
     * @dev Collateral ratio is capped to 100%.
     *
     * @dev Example (1_000_000 = 100%):
     * - Mint: user provides 1 collateral token to get 1 Dollar
     * - Redeem: user gets 1 collateral token for 1 Dollar
     *
     * @dev Example (900_000 = 90%):
     * - Mint: user provides 0.9 collateral token and 0.1 Governance token to get 1 Dollar
     * - Redeem: user gets 0.9 collateral token and 0.1 Governance token for 1 Dollar
     *
     * @param newCollateralRatio New collateral ratio
     */
    function setCollateralRatio(uint256 newCollateralRatio) internal {
        require(newCollateralRatio <= 1_000_000, "Collateral ratio too large");
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        poolStorage.collateralRatio = newCollateralRatio;

        emit CollateralRatioSet(newCollateralRatio);
    }

    /**
     * @notice Sets chainlink params for ETH/USD price feed
     * @param newPriceFeedAddress New chainlink price feed address for ETH/USD pair
     * @param newStalenessThreshold New threshold in seconds when chainlink's ETH/USD price feed answer should be considered stale
     */
    function setEthUsdChainLinkPriceFeed(
        address newPriceFeedAddress,
        uint256 newStalenessThreshold
    ) internal {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        poolStorage.ethUsdPriceFeedAddress = newPriceFeedAddress;
        poolStorage.ethUsdPriceFeedStalenessThreshold = newStalenessThreshold;

        emit EthUsdPriceFeedSet(newPriceFeedAddress, newStalenessThreshold);
    }

    /**
     * @notice Sets mint and redeem fees, 1_000_000 = 100%
     * @param collateralIndex Collateral token index
     * @param newMintFee New mint fee
     * @param newRedeemFee New redeem fee
     */
    function setFees(
        uint256 collateralIndex,
        uint256 newMintFee,
        uint256 newRedeemFee
    ) internal {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        poolStorage.mintingFee[collateralIndex] = newMintFee;
        poolStorage.redemptionFee[collateralIndex] = newRedeemFee;

        emit FeesSet(collateralIndex, newMintFee, newRedeemFee);
    }

    /**
     * @notice Sets a new pool address for Governance/ETH pair
     *
     * @dev Based on Curve's CurveTwocryptoOptimized contract. Used for fetching Governance token USD price.
     * How it works:
     * 1. Fetch Governance/ETH price from CurveTwocryptoOptimized's built-in oracle
     * 2. Fetch ETH/USD price from chainlink feed
     * 3. Calculate Governance token price in USD
     *
     * @param newGovernanceEthPoolAddress New pool address for Governance/ETH pair
     */
    function setGovernanceEthPoolAddress(
        address newGovernanceEthPoolAddress
    ) internal {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        poolStorage.governanceEthPoolAddress = newGovernanceEthPoolAddress;

        emit GovernanceEthPoolSet(newGovernanceEthPoolAddress);
    }

    /**
     * @notice Sets max amount of collateral for a particular collateral token
     * @param collateralIndex Collateral token index
     * @param newCeiling Max amount of collateral
     */
    function setPoolCeiling(
        uint256 collateralIndex,
        uint256 newCeiling
    ) internal {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        poolStorage.poolCeilings[collateralIndex] = newCeiling;

        emit PoolCeilingSet(collateralIndex, newCeiling);
    }

    /**
     * @notice Sets mint and redeem price thresholds, 1_000_000 = $1.00
     * @param newMintPriceThreshold New mint price threshold
     * @param newRedeemPriceThreshold New redeem price threshold
     */
    function setPriceThresholds(
        uint256 newMintPriceThreshold,
        uint256 newRedeemPriceThreshold
    ) internal {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        poolStorage.mintPriceThreshold = newMintPriceThreshold;
        poolStorage.redeemPriceThreshold = newRedeemPriceThreshold;

        emit PriceThresholdsSet(newMintPriceThreshold, newRedeemPriceThreshold);
    }

    /**
     * @notice Sets a redemption delay in blocks
     * @dev Redeeming is split in 2 actions:
     * @dev 1. `redeemDollar()`
     * @dev 2. `collectRedemption()`
     * @dev `newRedemptionDelayBlocks` sets number of blocks that should be mined after which user can call `collectRedemption()`
     * @param newRedemptionDelayBlocks Redemption delay in blocks
     */
    function setRedemptionDelayBlocks(
        uint256 newRedemptionDelayBlocks
    ) internal {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        poolStorage.redemptionDelayBlocks = newRedemptionDelayBlocks;

        emit RedemptionDelayBlocksSet(newRedemptionDelayBlocks);
    }

    /**
     * @notice Sets chainlink params for stable/USD price feed
     * @dev Here stable coin refers to the 1st coin in the Curve's stable/Dollar plain pool
     * @param newPriceFeedAddress New chainlink price feed address for stable/USD pair
     * @param newStalenessThreshold New threshold in seconds when chainlink's stable/USD price feed answer should be considered stale
     */
    function setStableUsdChainLinkPriceFeed(
        address newPriceFeedAddress,
        uint256 newStalenessThreshold
    ) internal {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        poolStorage.stableUsdPriceFeedAddress = newPriceFeedAddress;
        poolStorage
            .stableUsdPriceFeedStalenessThreshold = newStalenessThreshold;

        emit StableUsdPriceFeedSet(newPriceFeedAddress, newStalenessThreshold);
    }

    /**
     * @notice Toggles (i.e. enables/disables) a particular collateral token
     * @param collateralIndex Collateral token index
     */
    function toggleCollateral(uint256 collateralIndex) internal {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        address collateralAddress = poolStorage.collateralAddresses[
            collateralIndex
        ];
        poolStorage.isCollateralEnabled[collateralAddress] = !poolStorage
            .isCollateralEnabled[collateralAddress];

        emit CollateralToggled(
            collateralIndex,
            poolStorage.isCollateralEnabled[collateralAddress]
        );
    }

    /**
     * @notice Toggles pause for mint/redeem/borrow methods
     * @param collateralIndex Collateral token index
     * @param toggleIndex Method index. 0 - toggle mint pause, 1 - toggle redeem pause, 2 - toggle borrow by AMO pause
     */
    function toggleMintRedeemBorrow(
        uint256 collateralIndex,
        uint8 toggleIndex
    ) internal {
        UbiquityPoolStorage storage poolStorage = ubiquityPoolStorage();

        if (toggleIndex == 0)
            poolStorage.isMintPaused[collateralIndex] = !poolStorage
                .isMintPaused[collateralIndex];
        else if (toggleIndex == 1)
            poolStorage.isRedeemPaused[collateralIndex] = !poolStorage
                .isRedeemPaused[collateralIndex];
        else if (toggleIndex == 2)
            poolStorage.isBorrowPaused[collateralIndex] = !poolStorage
                .isBorrowPaused[collateralIndex];

        emit MintRedeemBorrowToggled(collateralIndex, toggleIndex);
    }
}
