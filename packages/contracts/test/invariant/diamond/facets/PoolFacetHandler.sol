// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {UbiquityPoolFacet} from "../../../../src/dollar/facets/UbiquityPoolFacet.sol";
import {MockChainLinkFeed} from "../../../../src/dollar/mocks/MockChainLinkFeed.sol";
import {MockCurveStableSwapNG} from "../../../../src/dollar/mocks/MockCurveStableSwapNG.sol";
import {MockERC20} from "../../../../src/dollar/mocks/MockERC20.sol";
import {IERC20Ubiquity} from "../../../../src/dollar/interfaces/IERC20Ubiquity.sol";
import {ManagerFacet} from "../../../../src/dollar/facets/ManagerFacet.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PoolFacetHandler is Test {
    using SafeMath for uint256;

    // mock three ChainLink price feeds, one for each token
    MockChainLinkFeed collateralTokenPriceFeed;
    MockChainLinkFeed stableUsdPriceFeed;
    MockChainLinkFeed ethUsdPriceFeed;
    MockERC20 collateralToken;

    ManagerFacet managerFacet;

    UbiquityPoolFacet ubiquityPoolFacet;
    IERC20Ubiquity dollar;
    IERC20Ubiquity governanceToken;

    // mock two users
    address admin;
    address user;

    // mock curve pool Stablecoin/Dollar
    MockCurveStableSwapNG curveDollarPlainPool;

    /**
     * @notice Constructs the PoolFacetHandler contract by initializing the necessary mocked contracts and addresses.
     * @dev This constructor sets up the initial state with provided mock price feeds, pool facet, and user addresses.
     * @param _collateralTokenPriceFeed The mock price feed for collateral tokens.
     * @param _stableUsdPriceFeed The mock price feed for USD stablecoin.
     * @param _ethUsdPriceFeed The mock price feed for ETH/USD.
     * @param _ubiquityPoolFacet The pool facet contract responsible for managing Ubiquity Dollars.
     * @param _admin The address with admin privileges, used for administrative actions in the pool.
     * @param _user The user address that interacts with the pool for testing purposes.
     * @param _curveDollarPlainPool The mocked Curve pool contract used for dollar-based operations.
     * @param _managerFacet The manager facet contract, which provides access to various addresses and core components of the Ubiquity system.
     * @param _collateralToken The mock ERC20 collateral token used in the pool for testing deposit and redemption functionalities.
     */

    constructor(
        MockChainLinkFeed _collateralTokenPriceFeed,
        MockChainLinkFeed _stableUsdPriceFeed,
        MockChainLinkFeed _ethUsdPriceFeed,
        UbiquityPoolFacet _ubiquityPoolFacet,
        address _admin,
        address _user,
        MockCurveStableSwapNG _curveDollarPlainPool,
        ManagerFacet _managerFacet,
        MockERC20 _collateralToken
    ) {
        collateralTokenPriceFeed = _collateralTokenPriceFeed;
        stableUsdPriceFeed = _stableUsdPriceFeed;
        ethUsdPriceFeed = _ethUsdPriceFeed;
        ubiquityPoolFacet = _ubiquityPoolFacet;
        admin = _admin;
        user = _user;
        curveDollarPlainPool = _curveDollarPlainPool;
        managerFacet = _managerFacet;
        collateralToken = _collateralToken;

        dollar = IERC20Ubiquity(managerFacet.dollarTokenAddress());
        governanceToken = IERC20Ubiquity(managerFacet.governanceTokenAddress());
    }

    /**
     * @notice Manipulates the Ubiquity Dollar price to a value above a set threshold.
     */
    function setDollarPriceAboveThreshold() public {
        curveDollarPlainPool.updateMockParams(1.01e18);
    }

    /**
     * @notice Manipulates the Ubiquity Dollar price to a value below a set threshold.
     */
    function setDollarPriceBelowThreshold() public {
        curveDollarPlainPool.updateMockParams(0.99e18);
    }

    /**
     * @notice Manipulates the minting and redemption fees for UbiquityPoolFacet.
     * @dev This function allows the admin to set the fees for minting and redeeming tokens in the pool.
     * It assumes the caller is the admin and pranks the transaction as the admin to set the fees.
     * The function also ensures that the provided mint and redeem fees fall within the acceptable range.
     * @param mintFee The fee to be set for minting, expressed in basis points (1/100 of a percent).
     * @param redeemFee The fee to be set for redeeming, expressed in basis points (1/100 of a percent).
     */
    function setMintAndRedeemFees(uint256 mintFee, uint256 redeemFee) public {
        vm.assume(mintFee >= 100000 && mintFee <= 200000);
        vm.assume(redeemFee >= 100000 && redeemFee <= 200000);

        vm.prank(admin);
        ubiquityPoolFacet.setFees(0, mintFee, redeemFee);
    }

    /**
     * @notice Simulates the process of a user collecting redeemed collateral and governance tokens after advancing a number of blocks.
     * @dev This function first advances the block number by the specified amount and then simulates the user calling the `collectRedemption` function.
     * @param _blocksToAdvance The number of blocks to advance before allowing redemption, constrained by an upper limit.
     */
    function collectRedemption(uint256 _blocksToAdvance) public {
        uint256 currentBlock = block.number;
        uint256 maxBlockAdvance = 100;

        // Ensure the number of blocks to advance is within a reasonable range
        vm.assume(_blocksToAdvance > 0 && _blocksToAdvance <= maxBlockAdvance);

        // Advance the block number by the specified amount
        vm.roll(currentBlock + _blocksToAdvance);

        // Simulate the `user` performing the redemption
        vm.prank(user);
        ubiquityPoolFacet.collectRedemption(0);
    }

    /**
     * @notice Manipulates the pool ceiling for UbiquityPoolFacet.
     * @dev This function allows the admin to set a new ceiling for the pool, which determines the maximum
     * amount of collateral that can be utilized in the pool. The function assumes the caller is the admin
     * and pranks the transaction as the admin to set the new ceiling.
     * @param newCeiling The new ceiling value to be set for the pool, representing the maximum amount
     * of collateral in the pool.
     */
    function setPoolCeiling(uint256 newCeiling) public {
        uint256 maxUint = type(uint128).max;
        vm.assume(newCeiling <= maxUint);

        vm.prank(admin);
        ubiquityPoolFacet.setPoolCeiling(0, newCeiling);
    }

    /**
     * @notice Manipulates the stable USD price and updates the corresponding collateral ratio.
     * @dev This function adjusts the price of the stable USD token using a mock ChainLink price feed.
     * It assumes the new price is within the specified range and updates the collateral ratio in the UbiquityPoolFacet.
     * @param _newPrice The new price of the stable USD token, scaled by 1e8 (e.g., a price of $1 is represented as 1e8).
     */
    function setStableUsdPrice(uint256 _newPrice) public {
        // Assume the price is between $0.70 and $1.00 (0.7e8 <= _newPrice <= 1e8)
        vm.assume(_newPrice >= 0.7e8 && _newPrice <= 1e8);

        stableUsdPriceFeed.updateMockParams(
            1, // round id
            int256(_newPrice), // Set the new price dynamically based on _newPrice
            block.timestamp, // started at
            block.timestamp, // updated at
            1 // answered in round
        );
    }

    /**
     * @notice Manipulates the collateral price and updates the corresponding collateral ratio.
     * @dev This function adjusts the price of the collateral token using a mock ChainLink price feed.
     * It assumes the new price is within the allowed range and updates the collateral ratio in the UbiquityPoolFacet.
     * @param _newPrice The new price of the collateral, scaled by 1e8 (e.g., a price of $1 is represented as 1e8).
     */
    function setCollateralPrice(int256 _newPrice) public {
        vm.assume(_newPrice >= 100_000_000 && _newPrice <= 150_000_000);

        collateralTokenPriceFeed.updateMockParams(
            1, // round id
            _newPrice,
            block.timestamp, // started at
            block.timestamp, // updated at
            1 // answered in round
        );

        ubiquityPoolFacet.updateChainLinkCollateralPrice(0);
    }

    /**
     * @notice Manipulates the ETH/USD price using a mock ChainLink price feed.
     * @dev This function assumes the new price is within the specified range and updates the ETH/USD price
     * in the corresponding mock price feed.
     * @param _newPrice The new ETH/USD price, scaled by 1e8 (e.g., a price of $1,000 is represented as 1000e8).
     */
    function setEthUsdPrice(uint256 _newPrice) public {
        vm.assume(_newPrice >= 1000e8 && _newPrice <= 5000e8);

        ethUsdPriceFeed.updateMockParams(
            1, // round id
            int256(_newPrice), // new price
            block.timestamp, // started at
            block.timestamp, // updated at
            1 // answered in round
        );
    }

    /**
     * @notice Mints Ubiquity Dollar tokens using specified collateral and governance token inputs.
     * @dev Assumes that the dollar amount is within a safe range, the minimum dollar output is less than or equal to the input amount,
     * and the collateral and governance inputs are valid. The function then pranks the specified user to simulate a mint transaction.
     * @param _dollarAmount The amount of Ubiquity Dollars to mint.
     * @param _dollarOutMin The minimum amount of Ubiquity Dollars expected to be received from the minting process.
     * @param _maxCollateralIn The maximum amount of collateral tokens to use for minting.
     * @param _maxGovernanceIn The maximum amount of governance tokens to use for minting.
     * @param _isOneToOne A boolean flag indicating whether the minting process should be executed on a one-to-one basis with the collateral.
     */
    function mintUbiquityDollars(
        uint256 _dollarAmount,
        uint256 _dollarOutMin,
        uint256 _maxCollateralIn,
        uint256 _maxGovernanceIn,
        bool _isOneToOne
    ) public {
        uint256 maxUint = type(uint128).max;
        uint256 collateralTotalSupply = collateralToken.totalSupply();

        vm.assume(_dollarAmount > 0 && _dollarAmount < maxUint);
        vm.assume(_dollarOutMin <= _dollarAmount);
        vm.assume(
            _maxCollateralIn > 0 && _maxCollateralIn < collateralTotalSupply
        );
        vm.assume(_maxGovernanceIn >= 0 && _maxGovernanceIn <= maxUint);

        vm.prank(user);
        ubiquityPoolFacet.mintDollar(
            0,
            _dollarAmount,
            _dollarOutMin,
            _maxCollateralIn,
            _maxGovernanceIn,
            _isOneToOne
        );
    }

    /**
     * @notice Redeems Ubiquity Dollar tokens for collateral and governance tokens.
     * @dev Assumes the dollar amount is within a safe range, and that the minimum expected governance and collateral outputs are valid.
     * The function then pranks the specified user to simulate a redemption transaction.
     * @param _dollarAmount The amount of Ubiquity Dollars to redeem.
     * @param _governanceOutMin The minimum amount of governance tokens expected to be received from the redemption process.
     * @param _collateralOutMin The minimum amount of collateral tokens expected to be received from the redemption process.
     */
    function redeemDollar(
        uint256 _dollarAmount,
        uint256 _governanceOutMin,
        uint256 _collateralOutMin
    ) public {
        uint256 maxUint = type(uint128).max;
        uint256 dollarTotalSupply = dollar.totalSupply();
        uint256 collateralTotalSupply = collateralToken.totalSupply();

        vm.assume(_dollarAmount > 0 && _dollarAmount < dollarTotalSupply);
        vm.assume(
            _collateralOutMin >= 0 && _collateralOutMin <= collateralTotalSupply
        );
        vm.assume(_governanceOutMin >= 0 && _governanceOutMin <= maxUint);

        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(
            0,
            _dollarAmount,
            _governanceOutMin,
            _collateralOutMin
        );
    }
}
