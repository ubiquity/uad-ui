// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/console.sol";
import {DiamondTestSetup} from "../DiamondTestSetup.sol";
import {IDollarAmoMinter} from "../../../src/dollar/interfaces/IDollarAmoMinter.sol";
import {LibUbiquityPool} from "../../../src/dollar/libraries/LibUbiquityPool.sol";
import {MockChainLinkFeed} from "../../../src/dollar/mocks/MockChainLinkFeed.sol";
import {MockERC20} from "../../../src/dollar/mocks/MockERC20.sol";
import {MockCurveStableSwapMetaNG} from "../../../src/dollar/mocks/MockCurveStableSwapMetaNG.sol";
import {MockCurveTwocryptoOptimized} from "../../../src/dollar/mocks/MockCurveTwocryptoOptimized.sol";

contract MockDollarAmoMinter is IDollarAmoMinter {
    function collateralDollarBalance() external pure returns (uint256) {
        return 0;
    }

    function collateralIndex() external pure returns (uint256) {
        return 0;
    }
}

contract UbiquityPoolFacetTest is DiamondTestSetup {
    MockDollarAmoMinter dollarAmoMinter;
    MockERC20 collateralToken;
    MockChainLinkFeed collateralTokenPriceFeed;
    MockCurveStableSwapMetaNG curveDollarMetaPool;
    MockCurveTwocryptoOptimized curveGovernanceEthPool;
    MockERC20 curveTriPoolLpToken;
    MockChainLinkFeed ethUsdPriceFeed;
    MockERC20 wethToken;

    address user = address(1);

    // Events
    event AmoMinterAdded(address amoMinterAddress);
    event AmoMinterRemoved(address amoMinterAddress);
    event CollateralPriceFeedSet(
        uint256 collateralIndex,
        address priceFeedAddress,
        uint256 stalenessThreshold
    );
    event CollateralPriceSet(uint256 collateralIndex, uint256 newPrice);
    event CollateralRatioSet(uint256 newCollateralRatio);
    event CollateralToggled(uint256 collateralIndex, bool newState);
    event EthUsdPriceFeedSet(
        address newPriceFeedAddress,
        uint256 newStalenessThreshold
    );
    event FeesSet(
        uint256 collateralIndex,
        uint256 newMintFee,
        uint256 newRedeemFee
    );
    event GovernanceEthPoolSet(address newGovernanceEthPoolAddress);
    event MintRedeemBorrowToggled(uint256 collateralIndex, uint8 toggleIndex);
    event PoolCeilingSet(uint256 collateralIndex, uint256 newCeiling);
    event PriceThresholdsSet(
        uint256 newMintPriceThreshold,
        uint256 newRedeemPriceThreshold
    );
    event RedemptionDelayBlocksSet(uint256 redemptionDelayBlocks);

    function setUp() public override {
        super.setUp();

        vm.startPrank(admin);

        // init collateral token
        collateralToken = new MockERC20("COLLATERAL", "CLT", 18);

        // init collateral price feed
        collateralTokenPriceFeed = new MockChainLinkFeed();

        // init ETH/USD price feed
        ethUsdPriceFeed = new MockChainLinkFeed();

        // init WETH token
        wethToken = new MockERC20("WETH", "WETH", 18);

        // init Curve 3CRV-LP token
        curveTriPoolLpToken = new MockERC20("3CRV", "3CRV", 18);

        // init Curve Dollar-3CRV LP metapool
        curveDollarMetaPool = new MockCurveStableSwapMetaNG(
            address(dollarToken),
            address(curveTriPoolLpToken)
        );

        // init Curve Governance-WETH crypto pool
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

        // set collateral price feed mock params
        collateralTokenPriceFeed.updateMockParams(
            1, // round id
            100_000_000, // answer, 100_000_000 = $1.00 (chainlink 8 decimals answer is converted to 6 decimals pool price)
            block.timestamp, // started at
            block.timestamp, // updated at
            1 // answered in round
        );

        // set ETH/USD price feed mock params
        ethUsdPriceFeed.updateMockParams(
            1, // round id
            3000_00000000, // answer, 3000_00000000 = $3000 (8 decimals)
            block.timestamp, // started at
            block.timestamp, // updated at
            1 // answered in round
        );

        // set ETH/Governance price to 30k in Curve pool mock
        curveGovernanceEthPool.updateMockParams(30_000e18);

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

        // enable collateral at index 0
        ubiquityPoolFacet.toggleCollateral(0);
        // set mint and redeem fees
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

        // init AMO minter
        dollarAmoMinter = new MockDollarAmoMinter();
        // add AMO minter
        ubiquityPoolFacet.addAmoMinter(address(dollarAmoMinter));

        // set metapool in manager facet
        managerFacet.setStableSwapMetaPoolAddress(address(curveDollarMetaPool));

        // stop being admin
        vm.stopPrank();

        // mint 2000 Governance tokens to the user
        deal(address(governanceToken), user, 2000e18);
        // mint 100 collateral tokens to the user
        collateralToken.mint(address(user), 100e18);
        // user approves the pool to transfer collateral
        vm.prank(user);
        collateralToken.approve(address(ubiquityPoolFacet), 100e18);
    }

    //=====================
    // Modifiers
    //=====================

    function testCollateralEnabled_ShouldRevert_IfCollateralIsDisabled()
        public
    {
        // admin disables collateral
        vm.prank(admin);
        ubiquityPoolFacet.toggleCollateral(0);

        // user tries to mint Dollars
        vm.prank(user);
        vm.expectRevert("Collateral disabled");
        ubiquityPoolFacet.mintDollar(0, 1, 1, 1, 1, false);
    }

    function testOnlyAmoMinter_ShouldRevert_IfCalledNoByAmoMinter() public {
        vm.prank(user);
        vm.expectRevert("Not an AMO Minter");
        ubiquityPoolFacet.amoMinterBorrow(1);
    }

    //=====================
    // Views
    //=====================

    function testAllCollaterals_ShouldReturnAllCollateralTokenAddresses()
        public
    {
        address[] memory collateralAddresses = ubiquityPoolFacet
            .allCollaterals();
        assertEq(collateralAddresses.length, 1);
        assertEq(collateralAddresses[0], address(collateralToken));
    }

    function testCollateralInformation_ShouldRevert_IfCollateralIsDisabled()
        public
    {
        // admin disables collateral
        vm.prank(admin);
        ubiquityPoolFacet.toggleCollateral(0);

        vm.expectRevert("Invalid collateral");
        ubiquityPoolFacet.collateralInformation(address(collateralToken));
    }

    function testCollateralInformation_ShouldReturnCollateralInformation()
        public
    {
        LibUbiquityPool.CollateralInformation memory info = ubiquityPoolFacet
            .collateralInformation(address(collateralToken));
        assertEq(info.index, 0);
        assertEq(info.symbol, "CLT");
        assertEq(info.collateralAddress, address(collateralToken));
        assertEq(
            info.collateralPriceFeedAddress,
            address(collateralTokenPriceFeed)
        );
        assertEq(info.collateralPriceFeedStalenessThreshold, 1 days);
        assertEq(info.isEnabled, true);
        assertEq(info.missingDecimals, 0);
        assertEq(info.price, 1_000_000);
        assertEq(info.poolCeiling, 50_000e18);
        assertEq(info.isMintPaused, false);
        assertEq(info.isRedeemPaused, false);
        assertEq(info.isBorrowPaused, false);
        assertEq(info.mintingFee, 10000);
        assertEq(info.redemptionFee, 20000);
    }

    function testCollateralRatio_ShouldReturnCollateralRatio() public {
        uint256 collateralRatio = ubiquityPoolFacet.collateralRatio();
        assertEq(collateralRatio, 1_000_000);
    }

    function testCollateralUsdBalance_ShouldReturnTotalAmountOfCollateralInUsd()
        public
    {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            990000 // redeem threshold
        );

        // user sends 100 collateral tokens and gets 99 Dollars
        vm.prank(user);
        ubiquityPoolFacet.mintDollar(
            0, // collateral index
            100e18, // Dollar amount
            99e18, // min amount of Dollars to mint
            100e18, // max collateral to send,
            0, // max Governance tokens to send
            false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
        );

        uint256 balanceTally = ubiquityPoolFacet.collateralUsdBalance();
        assertEq(balanceTally, 100e18);
    }

    function testEthUsdPriceFeedInformation_ShouldReturnEthUsdPriceFeedInformation()
        public
    {
        (address priceFeed, uint256 stalenessThreshold) = ubiquityPoolFacet
            .ethUsdPriceFeedInformation();
        assertEq(priceFeed, address(ethUsdPriceFeed));
        assertEq(stalenessThreshold, 1 days);
    }

    function testFreeCollateralBalance_ShouldReturnCollateralAmountAvailableForBorrowingByAmoMinters()
        public
    {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            1000000 // redeem threshold
        );

        // user sends 100 collateral tokens and gets 99 Dollars (-1% mint fee)
        vm.prank(user);
        ubiquityPoolFacet.mintDollar(
            0, // collateral index
            100e18, // Dollar amount
            99e18, // min amount of Dollars to mint
            100e18, // max collateral to send
            0, // max Governance tokens to send
            false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
        );

        // user redeems 99 Dollars for 97.02 (accounts for 2% redemption fee) collateral tokens
        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(
            0, // collateral index
            99e18, // Dollar amount
            0, // min Governance out
            90e18 // min collateral out
        );

        uint256 freeCollateralAmount = ubiquityPoolFacet.freeCollateralBalance(
            0
        );
        assertEq(freeCollateralAmount, 2.98e18);
    }

    function testGetDollarInCollateral_ShouldReturnAmountOfDollarsWhichShouldBeMintedForInputCollateral()
        public
    {
        uint256 amount = ubiquityPoolFacet.getDollarInCollateral(0, 100e18);
        assertEq(amount, 100e18);
    }

    function testGetDollarPriceUsd_ShouldReturnDollarPriceInUsd() public {
        uint256 dollarPriceUsd = ubiquityPoolFacet.getDollarPriceUsd();
        assertEq(dollarPriceUsd, 1_000_000);
    }

    function testGetGovernancePriceUsd_ShouldRevertOnInvalidChainlinkAnswer()
        public
    {
        // set invalid answer from chainlink
        ethUsdPriceFeed.updateMockParams(
            1, // round id
            0, // invalid answer
            block.timestamp, // started at
            block.timestamp, // updated at
            1 // answered in round
        );

        vm.expectRevert("Invalid price");
        ubiquityPoolFacet.getGovernancePriceUsd();
    }

    function testGetGovernancePriceUsd_ShouldRevertIfChainlinkAnswerIsStale()
        public
    {
        // set stale answer from chainlink
        collateralTokenPriceFeed.updateMockParams(
            1, // round id
            100_000_000, // answer, 100_000_000 = $1.00
            block.timestamp, // started at
            block.timestamp, // updated at
            1 // answered in round
        );

        // wait 1 day
        vm.warp(block.timestamp + 1 days);

        vm.expectRevert("Stale data");
        ubiquityPoolFacet.getGovernancePriceUsd();
    }

    function testGetGovernancePriceUsd_ShouldReturnGovernanceTokenPriceInUsd()
        public
    {
        uint256 governancePriceUsd = ubiquityPoolFacet.getGovernancePriceUsd();
        // 1 ETH = $3000, 1 ETH = 30_000 Governance tokens
        // Governance token USD price = (1 / 30000) * 3000 = 0.1
        assertEq(governancePriceUsd, 99999); // ~$0.09
    }

    function testGetRedeemCollateralBalance_ShouldReturnRedeemCollateralBalance()
        public
    {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            1000000 // redeem threshold
        );

        // user sends 100 collateral tokens and gets 99 Dollars (-1% mint fee)
        vm.prank(user);
        ubiquityPoolFacet.mintDollar(
            0, // collateral index
            100e18, // Dollar amount
            99e18, // min amount of Dollars to mint
            100e18, // max collateral to send
            0, // max Governance tokens to send
            false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
        );

        // user redeems 99 Dollars for 97.02 (accounts for 2% redemption fee) collateral tokens
        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(
            0, // collateral index
            99e18, // Dollar amount
            0, // min Governance out
            90e18 // min collateral out
        );

        uint256 redeemCollateralBalance = ubiquityPoolFacet
            .getRedeemCollateralBalance(user, 0);
        assertEq(redeemCollateralBalance, 97.02e18);
    }

    function testGetRedeemGovernanceBalance_ShouldReturnRedeemGovernanceBalance()
        public
    {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            1000000 // redeem threshold
        );

        // admin sets collateral ratio to 0%
        vm.prank(admin);
        ubiquityPoolFacet.setCollateralRatio(0);

        // user burns 1000 Governance tokens and gets 99 Dollars (-1% mint fee)
        vm.prank(user);
        ubiquityPoolFacet.mintDollar(
            0, // collateral index
            100e18, // Dollar amount
            99e18, // min amount of Dollars to mint
            0, // max collateral to send
            1100e18, // max Governance tokens to send
            false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
        );

        // user redeems 99 Dollars
        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(
            0, // collateral index
            99e18, // Dollar amount
            0, // min Governance out
            0 // min collateral out
        );

        assertEq(
            ubiquityPoolFacet.getRedeemGovernanceBalance(user),
            970209702097020970209
        );
    }

    function testGovernanceEthPoolAddress_ShouldReturnGovernanceEthPoolAddress()
        public
    {
        address governanceEthPoolAddress = ubiquityPoolFacet
            .governanceEthPoolAddress();
        assertEq(governanceEthPoolAddress, address(curveGovernanceEthPool));
    }

    //====================
    // Public functions
    //====================

    function testMintDollar_ShouldRevert_IfMintingIsPaused() public {
        // admin pauses minting
        vm.prank(admin);
        ubiquityPoolFacet.toggleMintRedeemBorrow(0, 0);

        vm.prank(user);
        vm.expectRevert("Minting is paused");
        ubiquityPoolFacet.mintDollar(
            0, // collateral index
            100e18, // Dollar amount
            90e18, // min amount of Dollars to mint
            100e18, // max collateral to send
            0, // max Governance tokens to send
            false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
        );
    }

    function testMintDollar_ShouldRevert_IfDollarPriceUsdIsTooLow() public {
        vm.prank(user);
        vm.expectRevert("Dollar price too low");
        ubiquityPoolFacet.mintDollar(
            0, // collateral index
            100e18, // Dollar amount
            90e18, // min amount of Dollars to mint
            100e18, // max collateral to send
            0, // max Governance tokens to send
            false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
        );
    }

    function testMintDollar_ShouldRevert_OnDollarAmountSlippage() public {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            990000 // redeem threshold
        );

        vm.prank(user);
        vm.expectRevert("Dollar slippage");
        ubiquityPoolFacet.mintDollar(
            0, // collateral index
            100e18, // Dollar amount
            100e18, // min amount of Dollars to mint
            100e18, // max collateral to send
            0, // max Governance tokens to send
            false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
        );
    }

    function testMintDollar_ShouldRevert_OnCollateralAmountSlippage() public {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            990000 // redeem threshold
        );

        vm.prank(user);
        vm.expectRevert("Collateral slippage");
        ubiquityPoolFacet.mintDollar(
            0, // collateral index
            100e18, // Dollar amount
            90e18, // min amount of Dollars to mint
            10e18, // max collateral to send
            0, // max Governance tokens to send
            false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
        );
    }

    function testMintDollar_ShouldRevert_OnGovernanceAmountSlippage() public {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            990000 // redeem threshold
        );

        // admin sets collateral ratio to 0%
        vm.prank(admin);
        ubiquityPoolFacet.setCollateralRatio(0);

        vm.prank(user);
        vm.expectRevert("Governance slippage");
        ubiquityPoolFacet.mintDollar(
            0, // collateral index
            100e18, // Dollar amount
            90e18, // min amount of Dollars to mint
            10e18, // max collateral to send
            0, // max Governance tokens to send
            false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
        );
    }

    function testMintDollar_ShouldRevert_OnReachingPoolCeiling() public {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            990000 // redeem threshold
        );

        vm.prank(user);
        vm.expectRevert("Pool ceiling");
        ubiquityPoolFacet.mintDollar(
            0, // collateral index
            60_000e18, // Dollar amount
            59_000e18, // min amount of Dollars to mint
            60_000e18, // max collateral to send
            0, // max Governance tokens to send
            false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
        );
    }

    function testMintDollar_ShouldMintDollars_IfUserForcesOneToOneOverride()
        public
    {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            990000 // redeem threshold
        );

        // admin sets collateral ratio to 0%
        vm.prank(admin);
        ubiquityPoolFacet.setCollateralRatio(0);

        // balances before
        assertEq(collateralToken.balanceOf(address(ubiquityPoolFacet)), 0);
        assertEq(dollarToken.balanceOf(user), 0);
        assertEq(governanceToken.balanceOf(user), 2000e18);

        vm.prank(user);
        (
            uint256 totalDollarMint,
            uint256 collateralNeeded,
            uint256 governanceNeeded
        ) = ubiquityPoolFacet.mintDollar(
                0, // collateral index
                100e18, // Dollar amount
                99e18, // min amount of Dollars to mint
                100e18, // max collateral to send
                1100e18, // max Governance tokens to send
                true // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
            );

        assertEq(totalDollarMint, 99e18);
        assertEq(collateralNeeded, 100e18);
        assertEq(governanceNeeded, 0);

        // balances after
        assertEq(collateralToken.balanceOf(address(ubiquityPoolFacet)), 100e18);
        assertEq(dollarToken.balanceOf(user), 99e18);
        assertEq(governanceToken.balanceOf(user), 2000e18);
    }

    function testMintDollar_ShouldMintDollars_IfCollateralRatioIs100() public {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            990000 // redeem threshold
        );

        // balances before
        assertEq(collateralToken.balanceOf(address(ubiquityPoolFacet)), 0);
        assertEq(dollarToken.balanceOf(user), 0);
        assertEq(governanceToken.balanceOf(user), 2000e18);

        vm.prank(user);
        (
            uint256 totalDollarMint,
            uint256 collateralNeeded,
            uint256 governanceNeeded
        ) = ubiquityPoolFacet.mintDollar(
                0, // collateral index
                100e18, // Dollar amount
                99e18, // min amount of Dollars to mint
                100e18, // max collateral to send
                0, // max Governance tokens to send
                false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
            );
        assertEq(totalDollarMint, 99e18);
        assertEq(collateralNeeded, 100e18);
        assertEq(governanceNeeded, 0);

        // balances after
        assertEq(collateralToken.balanceOf(address(ubiquityPoolFacet)), 100e18);
        assertEq(dollarToken.balanceOf(user), 99e18);
        assertEq(governanceToken.balanceOf(user), 2000e18);
    }

    function testMintDollar_ShouldMintDollars_IfCollateralRatioIs0() public {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            990000 // redeem threshold
        );

        // admin sets collateral ratio to 0%
        vm.prank(admin);
        ubiquityPoolFacet.setCollateralRatio(0);

        // balances before
        assertEq(collateralToken.balanceOf(address(ubiquityPoolFacet)), 0);
        assertEq(dollarToken.balanceOf(user), 0);
        assertEq(governanceToken.balanceOf(user), 2000e18);

        vm.prank(user);
        (
            uint256 totalDollarMint,
            uint256 collateralNeeded,
            uint256 governanceNeeded
        ) = ubiquityPoolFacet.mintDollar(
                0, // collateral index
                100e18, // Dollar amount
                99e18, // min amount of Dollars to mint
                100e18, // max collateral to send
                1100e18, // max Governance tokens to send
                false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
            );

        assertEq(totalDollarMint, 99e18);
        assertEq(collateralNeeded, 0);
        assertEq(governanceNeeded, 1000010000100001000010); // ~1000.01 = 100 Dollar * $0.1 Governance from oracle

        // balances after
        assertEq(collateralToken.balanceOf(address(ubiquityPoolFacet)), 0);
        assertEq(dollarToken.balanceOf(user), 99e18);
        assertEq(governanceToken.balanceOf(user), 2000e18 - governanceNeeded);
    }

    function testMintDollar_ShouldMintDollars_IfCollateralRatioIs95() public {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            990000 // redeem threshold
        );

        // admin sets collateral ratio to 95%
        vm.prank(admin);
        ubiquityPoolFacet.setCollateralRatio(950_000);

        // balances before
        assertEq(collateralToken.balanceOf(address(ubiquityPoolFacet)), 0);
        assertEq(dollarToken.balanceOf(user), 0);
        assertEq(governanceToken.balanceOf(user), 2000e18);

        vm.prank(user);
        (
            uint256 totalDollarMint,
            uint256 collateralNeeded,
            uint256 governanceNeeded
        ) = ubiquityPoolFacet.mintDollar(
                0, // collateral index
                100e18, // Dollar amount
                99e18, // min amount of Dollars to mint
                100e18, // max collateral to send
                1100e18, // max Governance tokens to send
                false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
            );

        assertEq(totalDollarMint, 99e18);
        assertEq(collateralNeeded, 95e18);
        assertEq(governanceNeeded, 50000500005000050000); // ~50 Governance tokens = $5 USD / $0.1 Governance from oracle

        // balances after
        assertEq(collateralToken.balanceOf(address(ubiquityPoolFacet)), 95e18);
        assertEq(dollarToken.balanceOf(user), 99e18);
        assertEq(governanceToken.balanceOf(user), 2000e18 - governanceNeeded);
    }

    function testRedeemDollar_ShouldRevert_IfRedeemingIsPaused() public {
        // admin pauses redeeming
        vm.prank(admin);
        ubiquityPoolFacet.toggleMintRedeemBorrow(0, 1);

        vm.prank(user);
        vm.expectRevert("Redeeming is paused");
        ubiquityPoolFacet.redeemDollar(
            0, // collateral index
            100e18, // Dollar amount
            0, // min Governance out
            90e18 // min collateral out
        );
    }

    function testRedeemDollar_ShouldRevert_IfDollarPriceUsdIsTooHigh() public {
        vm.prank(user);
        vm.expectRevert("Dollar price too high");
        ubiquityPoolFacet.redeemDollar(
            0, // collateral index
            100e18, // Dollar amount
            0, // min Governance out
            90e18 // min collateral out
        );
    }

    function testRedeemDollar_ShouldRevert_OnInsufficientPoolCollateral()
        public
    {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            1000000 // redeem threshold
        );

        vm.prank(user);
        vm.expectRevert("Insufficient pool collateral");
        ubiquityPoolFacet.redeemDollar(
            0, // collateral index
            100e18, // Dollar amount
            0, // min Governance out
            90e18 // min collateral out
        );
    }

    function testRedeemDollar_ShouldRevert_OnCollateralSlippage() public {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            1000000 // redeem threshold
        );

        // user sends 100 collateral tokens and gets 99 Dollars (-1% mint fee)
        vm.prank(user);
        ubiquityPoolFacet.mintDollar(
            0, // collateral index
            100e18, // Dollar amount
            99e18, // min amount of Dollars to mint
            100e18, // max collateral to send
            0, // max Governance tokens to send
            false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
        );

        vm.prank(user);
        vm.expectRevert("Collateral slippage");
        ubiquityPoolFacet.redeemDollar(
            0, // collateral index
            100e18, // Dollar amount
            0, // min Governance out
            100e18 // min collateral out
        );
    }

    function testRedeemDollar_ShouldRevert_OnGovernanceSlippage() public {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            1000000 // redeem threshold
        );

        // admin sets collateral ratio to 0%
        vm.prank(admin);
        ubiquityPoolFacet.setCollateralRatio(0);

        // user burns ~1000 Governance tokens and gets 99 Dollars (-1% mint fee)
        vm.prank(user);
        ubiquityPoolFacet.mintDollar(
            0, // collateral index
            100e18, // Dollar amount
            99e18, // min amount of Dollars to mint
            0, // max collateral to send
            1100e18, // max Governance tokens to send
            false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
        );

        vm.prank(user);
        vm.expectRevert("Governance slippage");
        ubiquityPoolFacet.redeemDollar(
            0, // collateral index
            99e18, // Dollar amount
            1100e18, // min Governance out
            0 // min collateral out
        );
    }

    function testRedeemDollar_ShouldRedeemCollateral_IfCollateralRatioIs100()
        public
    {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            1000000 // redeem threshold
        );

        // user sends 100 collateral tokens and gets 99 Dollars (-1% mint fee)
        vm.prank(user);
        ubiquityPoolFacet.mintDollar(
            0, // collateral index
            100e18, // Dollar amount
            99e18, // min amount of Dollars to mint
            100e18, // max collateral to send
            0, // max Governance tokens to send
            false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
        );

        // balances before
        assertEq(dollarToken.balanceOf(user), 99e18);
        assertEq(governanceToken.balanceOf(user), 2000e18);
        assertEq(governanceToken.balanceOf(address(ubiquityPoolFacet)), 0);
        assertEq(ubiquityPoolFacet.getRedeemCollateralBalance(user, 0), 0);
        assertEq(ubiquityPoolFacet.getRedeemGovernanceBalance(user), 0);

        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(
            0, // collateral index
            99e18, // Dollar amount
            0, // min Governance out
            90e18 // min collateral out
        );

        // balances after
        assertEq(dollarToken.balanceOf(user), 0);
        assertEq(governanceToken.balanceOf(user), 2000e18);
        assertEq(governanceToken.balanceOf(address(ubiquityPoolFacet)), 0);
        assertEq(
            ubiquityPoolFacet.getRedeemCollateralBalance(user, 0),
            97.02 ether
        );
        assertEq(ubiquityPoolFacet.getRedeemGovernanceBalance(user), 0);
    }

    function testRedeemDollar_ShouldRedeemCollateral_IfCollateralRatioIs0()
        public
    {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            1000000 // redeem threshold
        );

        // admin sets collateral ratio to 0%
        vm.prank(admin);
        ubiquityPoolFacet.setCollateralRatio(0);

        // user burns 1000 Governance tokens and gets 99 Dollars (-1% mint fee)
        vm.prank(user);
        ubiquityPoolFacet.mintDollar(
            0, // collateral index
            100e18, // Dollar amount
            99e18, // min amount of Dollars to mint
            0, // max collateral to send
            1100e18, // max Governance tokens to send
            false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
        );

        // balances before
        assertEq(dollarToken.balanceOf(user), 99e18);
        assertEq(governanceToken.balanceOf(user), 999989999899998999990);
        assertEq(governanceToken.balanceOf(address(ubiquityPoolFacet)), 0);
        assertEq(ubiquityPoolFacet.getRedeemCollateralBalance(user, 0), 0);
        assertEq(ubiquityPoolFacet.getRedeemGovernanceBalance(user), 0);

        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(
            0, // collateral index
            99e18, // Dollar amount
            0, // min Governance out
            0 // min collateral out
        );

        // balances after
        assertEq(dollarToken.balanceOf(user), 0);
        assertEq(governanceToken.balanceOf(user), 999989999899998999990);
        assertEq(
            governanceToken.balanceOf(address(ubiquityPoolFacet)),
            970209702097020970209
        );
        assertEq(ubiquityPoolFacet.getRedeemCollateralBalance(user, 0), 0);
        assertEq(
            ubiquityPoolFacet.getRedeemGovernanceBalance(user),
            970209702097020970209
        );
    }

    function testRedeemDollar_ShouldRedeemCollateral_IfCollateralRatioIs95()
        public
    {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            1000000 // redeem threshold
        );

        // admin sets collateral ratio to 95%
        vm.prank(admin);
        ubiquityPoolFacet.setCollateralRatio(950_000);

        // user burns 50 Governance tokens (worth $0.1) + 95 collateral tokens and gets 99 Dollars (-1% mint fee)
        vm.prank(user);
        ubiquityPoolFacet.mintDollar(
            0, // collateral index
            100e18, // Dollar amount
            99e18, // min amount of Dollars to mint
            100e18, // max collateral to send
            1100e18, // max Governance tokens to send
            false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
        );

        // balances before
        assertEq(dollarToken.balanceOf(user), 99e18);
        assertEq(governanceToken.balanceOf(user), 1949999499994999950000); // ~1950
        assertEq(governanceToken.balanceOf(address(ubiquityPoolFacet)), 0);
        assertEq(ubiquityPoolFacet.getRedeemCollateralBalance(user, 0), 0);
        assertEq(ubiquityPoolFacet.getRedeemGovernanceBalance(user), 0);

        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(
            0, // collateral index
            99e18, // Dollar amount
            0, // min Governance out
            0 // min collateral out
        );

        // balances after
        assertEq(dollarToken.balanceOf(user), 0);
        assertEq(governanceToken.balanceOf(user), 1949999499994999950000); // ~1950
        assertEq(
            governanceToken.balanceOf(address(ubiquityPoolFacet)),
            48510485104851048510
        ); // ~48.5
        assertEq(
            ubiquityPoolFacet.getRedeemCollateralBalance(user, 0),
            92169000000000000000
        ); // ~92
        assertEq(
            ubiquityPoolFacet.getRedeemGovernanceBalance(user),
            48510485104851048510
        ); // ~48.5
    }

    function testCollectRedemption_ShouldRevert_IfRedeemingIsPaused() public {
        // admin pauses redeeming
        vm.prank(admin);
        ubiquityPoolFacet.toggleMintRedeemBorrow(0, 1);

        vm.prank(user);
        vm.expectRevert("Redeeming is paused");
        ubiquityPoolFacet.collectRedemption(0);
    }

    function testCollectRedemption_ShouldRevert_IfNotEnoughBlocksHaveBeenMined()
        public
    {
        vm.prank(user);
        vm.expectRevert("Too soon to collect redemption");
        ubiquityPoolFacet.collectRedemption(0);
    }

    function testCollectRedemption_ShouldCollectRedemption() public {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            1000000 // redeem threshold
        );

        // admin sets collateral ratio to 95%
        vm.prank(admin);
        ubiquityPoolFacet.setCollateralRatio(950_000);

        // user burns 50 Governance tokens (worth $0.1) + 95 collateral tokens and gets 99 Dollars (-1% mint fee)
        vm.prank(user);
        ubiquityPoolFacet.mintDollar(
            0, // collateral index
            100e18, // Dollar amount
            99e18, // min amount of Dollars to mint
            100e18, // max collateral to send
            1100e18, // max Governance tokens to send
            false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
        );

        // user redeems 99 Dollars for collateral and Governance tokens
        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(
            0, // collateral index
            99e18, // Dollar amount
            0, // min Governance out
            90e18 // min collateral out
        );

        // wait 3 blocks for collecting redemption to become active
        vm.roll(block.number + 3);

        // balances before
        assertEq(collateralToken.balanceOf(address(ubiquityPoolFacet)), 95e18);
        assertEq(collateralToken.balanceOf(user), 5e18);
        assertEq(
            governanceToken.balanceOf(address(ubiquityPoolFacet)),
            48510485104851048510
        ); // ~48
        assertEq(governanceToken.balanceOf(user), 1949999499994999950000); // ~1950

        vm.prank(user);
        (uint256 governanceAmount, uint256 collateralAmount) = ubiquityPoolFacet
            .collectRedemption(0);
        assertEq(governanceAmount, 48510485104851048510); // ~48
        assertEq(collateralAmount, 92169000000000000000); // ~92 = $95 - 2% redemption fee

        // balances after
        assertEq(
            collateralToken.balanceOf(address(ubiquityPoolFacet)),
            2.831 ether
        ); // redemption fee left in the pool
        assertEq(collateralToken.balanceOf(user), 97.169 ether);
        assertEq(governanceToken.balanceOf(address(ubiquityPoolFacet)), 0);
        assertEq(governanceToken.balanceOf(user), 1998509985099850998510); // ~1998
    }

    function testCollectRedemption_ShouldRevert_IfCollateralDisabled() public {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            1000000 // redeem threshold
        );

        vm.prank(user);
        ubiquityPoolFacet.mintDollar(
            0, // collateral index
            100e18, // Dollar amount
            99e18, // min amount of Dollars to mint
            100e18, // max collateral to send
            0, // max Governance tokens to send
            false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
        );

        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(
            0, // collateral index
            99e18, // Dollar amount
            0, // min Governance out
            90e18 // min collateral out
        );

        // wait 3 blocks for collecting redemption to become active
        vm.roll(3);

        vm.prank(admin);
        ubiquityPoolFacet.toggleCollateral(0);

        vm.prank(user);
        vm.expectRevert("Collateral disabled");
        ubiquityPoolFacet.collectRedemption(0);
    }

    function testUpdateChainLinkCollateralPrice_ShouldRevert_IfChainlinkAnswerIsInvalid()
        public
    {
        // set invalid answer from chainlink
        collateralTokenPriceFeed.updateMockParams(
            1, // round id
            0, // invalid answer
            block.timestamp, // started at
            block.timestamp, // updated at
            1 // answered in round
        );

        vm.expectRevert("Invalid price");
        ubiquityPoolFacet.updateChainLinkCollateralPrice(0);
    }

    function testUpdateChainLinkCollateralPrice_ShouldRevert_IfChainlinkAnswerIsStale()
        public
    {
        // set stale answer from chainlink
        collateralTokenPriceFeed.updateMockParams(
            1, // round id
            100_000_000, // answer, 100_000_000 = $1.00
            block.timestamp, // started at
            block.timestamp, // updated at
            1 // answered in round
        );

        // wait 1 day
        vm.warp(block.timestamp + 1 days);

        vm.expectRevert("Stale data");
        ubiquityPoolFacet.updateChainLinkCollateralPrice(0);
    }

    function testUpdateChainLinkCollateralPrice_ShouldUpdateCollateralPrice()
        public
    {
        // before
        LibUbiquityPool.CollateralInformation memory info = ubiquityPoolFacet
            .collateralInformation(address(collateralToken));
        assertEq(info.price, 1_000_000);

        // set answer from chainlink
        collateralTokenPriceFeed.updateMockParams(
            1, // round id
            99_000_000, // answer, 99_000_000 = $0.99
            block.timestamp, // started at
            block.timestamp, // updated at
            1 // answered in round
        );

        // update collateral price
        ubiquityPoolFacet.updateChainLinkCollateralPrice(0);

        // after
        info = ubiquityPoolFacet.collateralInformation(
            address(collateralToken)
        );
        assertEq(info.price, 990_000);
    }

    //=========================
    // AMO minters functions
    //=========================

    function testAmoMinterBorrow_ShouldRevert_IfBorrowingIsPaused() public {
        // admin pauses borrowing by AMOs
        vm.prank(admin);
        ubiquityPoolFacet.toggleMintRedeemBorrow(0, 2);

        // Dollar AMO minter tries to borrow collateral
        vm.prank(address(dollarAmoMinter));
        vm.expectRevert("Borrowing is paused");
        ubiquityPoolFacet.amoMinterBorrow(1);
    }

    function testAmoMinterBorrow_ShouldRevert_IfCollateralIsDisabled() public {
        // admin disables collateral
        vm.prank(admin);
        ubiquityPoolFacet.toggleCollateral(0);

        // Dollar AMO minter tries to borrow collateral
        vm.prank(address(dollarAmoMinter));
        vm.expectRevert("Collateral disabled");
        ubiquityPoolFacet.amoMinterBorrow(1);
    }

    function testAmoMinterBorrow_ShouldRevert_IfThereIsNotEnoughFreeCollateral()
        public
    {
        vm.prank(admin);
        ubiquityPoolFacet.setPriceThresholds(
            1000000, // mint threshold
            1000000 // redeem threshold
        );

        // user sends 100 collateral tokens and gets 99 Dollars (-1% mint fee)
        vm.prank(user);
        ubiquityPoolFacet.mintDollar(
            0, // collateral index
            100e18, // Dollar amount
            99e18, // min amount of Dollars to mint
            100e18, // max collateral to send
            0, // max Governance tokens to send
            false // force 1-to-1 mint (i.e. provide only collateral without Governance tokens)
        );

        // user redeems 99 Dollars for 97.02 (accounts for 2% redemption fee) collateral tokens
        vm.prank(user);
        ubiquityPoolFacet.redeemDollar(
            0, // collateral index
            99e18, // Dollar amount
            0, // min Governance out
            90e18 // min collateral out
        );

        // get free collateral amount, returns 2.98e18
        uint256 freeCollateralAmount = ubiquityPoolFacet.freeCollateralBalance(
            0
        );
        assertEq(freeCollateralAmount, 2.98e18);

        // Dollar AMO minter tries to borrow more collateral than available after users' redemptions
        vm.prank(address(dollarAmoMinter));
        vm.expectRevert("Not enough free collateral");
        ubiquityPoolFacet.amoMinterBorrow(freeCollateralAmount + 1);
    }

    function testAmoMinterBorrow_ShouldBorrowCollateral() public {
        // mint 100 collateral tokens to the pool
        collateralToken.mint(address(ubiquityPoolFacet), 100e18);

        assertEq(collateralToken.balanceOf(address(ubiquityPoolFacet)), 100e18);
        assertEq(collateralToken.balanceOf(address(dollarAmoMinter)), 0);

        vm.prank(address(dollarAmoMinter));
        ubiquityPoolFacet.amoMinterBorrow(100e18);

        assertEq(collateralToken.balanceOf(address(ubiquityPoolFacet)), 0);
        assertEq(collateralToken.balanceOf(address(dollarAmoMinter)), 100e18);
    }

    //========================
    // Restricted functions
    //========================

    function testAddAmoMinter_ShouldRevert_IfAmoMinterIsZeroAddress() public {
        vm.startPrank(admin);

        vm.expectRevert("Zero address detected");
        ubiquityPoolFacet.addAmoMinter(address(0));

        vm.stopPrank();
    }

    function testAddAmoMinter_ShouldRevert_IfAmoMinterHasInvalidInterface()
        public
    {
        vm.startPrank(admin);

        vm.expectRevert();
        ubiquityPoolFacet.addAmoMinter(address(1));

        vm.stopPrank();
    }

    function testAddAmoMinter_ShouldAddAmoMinter() public {
        vm.startPrank(admin);

        vm.expectEmit(address(ubiquityPoolFacet));
        emit AmoMinterAdded(address(dollarAmoMinter));
        ubiquityPoolFacet.addAmoMinter(address(dollarAmoMinter));

        vm.stopPrank();
    }

    function testAddCollateralToken_ShouldAddNewTokenAsCollateral() public {
        LibUbiquityPool.CollateralInformation memory info = ubiquityPoolFacet
            .collateralInformation(address(collateralToken));
        assertEq(info.index, 0);
        assertEq(info.symbol, "CLT");
        assertEq(info.collateralAddress, address(collateralToken));
        assertEq(
            info.collateralPriceFeedAddress,
            address(collateralTokenPriceFeed)
        );
        assertEq(info.collateralPriceFeedStalenessThreshold, 1 days);
        assertEq(info.isEnabled, true);
        assertEq(info.missingDecimals, 0);
        assertEq(info.price, 1_000_000);
        assertEq(info.poolCeiling, 50_000e18);
        assertEq(info.isMintPaused, false);
        assertEq(info.isRedeemPaused, false);
        assertEq(info.isBorrowPaused, false);
        assertEq(info.mintingFee, 10000);
        assertEq(info.redemptionFee, 20000);
    }

    function testAddCollateralToken_ShouldRevertIfCollateralExists() public {
        uint256 poolCeiling = 50_000e18;
        vm.startPrank(admin);
        vm.expectRevert("Collateral already added");
        ubiquityPoolFacet.addCollateralToken(
            address(collateralToken),
            address(collateralTokenPriceFeed),
            poolCeiling
        );
    }

    function testRemoveAmoMinter_ShouldRemoveAmoMinter() public {
        vm.startPrank(admin);

        vm.expectEmit(address(ubiquityPoolFacet));
        emit AmoMinterRemoved(address(dollarAmoMinter));
        ubiquityPoolFacet.removeAmoMinter(address(dollarAmoMinter));

        vm.stopPrank();
    }

    function testSetCollateralChainLinkPriceFeed_ShouldRevertIfCollateralDoesNotExist()
        public
    {
        vm.prank(admin);
        vm.expectRevert("Collateral does not exist");
        address invalidCollateralAddress = address(0);
        address newPriceFeedAddress = address(1);
        uint256 newStalenessThreshold = 1 days;
        ubiquityPoolFacet.setCollateralChainLinkPriceFeed(
            invalidCollateralAddress,
            newPriceFeedAddress,
            newStalenessThreshold
        );
    }

    function testSetCollateralChainLinkPriceFeed_ShouldSetPriceFeed() public {
        vm.startPrank(admin);

        LibUbiquityPool.CollateralInformation memory info = ubiquityPoolFacet
            .collateralInformation(address(collateralToken));
        assertEq(
            info.collateralPriceFeedAddress,
            address(collateralTokenPriceFeed)
        );
        assertEq(info.collateralPriceFeedStalenessThreshold, 1 days);

        address newPriceFeedAddress = address(1);
        uint256 newStalenessThreshold = 2 days;
        vm.expectEmit(address(ubiquityPoolFacet));
        emit CollateralPriceFeedSet(
            0,
            newPriceFeedAddress,
            newStalenessThreshold
        );
        ubiquityPoolFacet.setCollateralChainLinkPriceFeed(
            address(collateralToken),
            newPriceFeedAddress,
            newStalenessThreshold
        );

        info = ubiquityPoolFacet.collateralInformation(
            address(collateralToken)
        );
        assertEq(info.collateralPriceFeedAddress, newPriceFeedAddress);
        assertEq(
            info.collateralPriceFeedStalenessThreshold,
            newStalenessThreshold
        );

        vm.stopPrank();
    }

    function testSetCollateralRatio_ShouldSetCollateralRatio() public {
        vm.startPrank(admin);

        uint256 oldCollateralRatio = ubiquityPoolFacet.collateralRatio();
        assertEq(oldCollateralRatio, 1_000_000);

        uint256 newCollateralRatio = 900_000;
        vm.expectEmit(address(ubiquityPoolFacet));
        emit CollateralRatioSet(newCollateralRatio);
        ubiquityPoolFacet.setCollateralRatio(newCollateralRatio);

        assertEq(ubiquityPoolFacet.collateralRatio(), newCollateralRatio);

        vm.stopPrank();
    }

    function testSetCollateralRatio_ShouldRevertIfRatioLargerThanOneHundredPercent()
        public
    {
        vm.startPrank(admin);
        uint256 oldCollateralRatio = ubiquityPoolFacet.collateralRatio();
        assertEq(oldCollateralRatio, 1_000_000);

        uint256 newCollateralRatio = 1_000_001;
        vm.expectRevert("Collateral ratio too large");
        ubiquityPoolFacet.setCollateralRatio(newCollateralRatio);

        vm.stopPrank();
    }

    function testSetEthUsdChainLinkPriceFeed_ShouldSetEthUsdChainLinkPriceFeed()
        public
    {
        vm.startPrank(admin);

        (
            address oldPriceFeedAddress,
            uint256 oldStalenessThreshold
        ) = ubiquityPoolFacet.ethUsdPriceFeedInformation();
        assertEq(oldPriceFeedAddress, address(ethUsdPriceFeed));
        assertEq(oldStalenessThreshold, 1 days);

        address newPriceFeedAddress = address(1);
        uint256 newStalenessThreshold = 2 days;
        vm.expectEmit(address(ubiquityPoolFacet));
        emit EthUsdPriceFeedSet(newPriceFeedAddress, newStalenessThreshold);
        ubiquityPoolFacet.setEthUsdChainLinkPriceFeed(
            newPriceFeedAddress,
            newStalenessThreshold
        );

        (
            address updatedPriceFeedAddress,
            uint256 updatedStalenessThreshold
        ) = ubiquityPoolFacet.ethUsdPriceFeedInformation();
        assertEq(updatedPriceFeedAddress, newPriceFeedAddress);
        assertEq(updatedStalenessThreshold, newStalenessThreshold);

        vm.stopPrank();
    }

    function testSetFees_ShouldSetMintAndRedeemFees() public {
        vm.startPrank(admin);

        vm.expectEmit(address(ubiquityPoolFacet));
        emit FeesSet(0, 1, 2);
        ubiquityPoolFacet.setFees(0, 1, 2);

        vm.stopPrank();
    }

    function testSetGovernanceEthPoolAddress_ShouldSetGovernanceEthPoolAddress()
        public
    {
        vm.startPrank(admin);

        address oldGovernanceEthPoolAddress = ubiquityPoolFacet
            .governanceEthPoolAddress();
        assertEq(oldGovernanceEthPoolAddress, address(curveGovernanceEthPool));

        address newGovernanceEthPoolAddress = address(1);
        vm.expectEmit(address(ubiquityPoolFacet));
        emit GovernanceEthPoolSet(newGovernanceEthPoolAddress);
        ubiquityPoolFacet.setGovernanceEthPoolAddress(
            newGovernanceEthPoolAddress
        );

        assertEq(
            ubiquityPoolFacet.governanceEthPoolAddress(),
            newGovernanceEthPoolAddress
        );

        vm.stopPrank();
    }

    function testSetPoolCeiling_ShouldSetMaxAmountOfTokensAllowedForCollateral()
        public
    {
        vm.startPrank(admin);

        LibUbiquityPool.CollateralInformation memory info = ubiquityPoolFacet
            .collateralInformation(address(collateralToken));
        assertEq(info.poolCeiling, 50_000e18);

        vm.expectEmit(address(ubiquityPoolFacet));
        emit PoolCeilingSet(0, 10_000e18);
        ubiquityPoolFacet.setPoolCeiling(0, 10_000e18);

        info = ubiquityPoolFacet.collateralInformation(
            address(collateralToken)
        );
        assertEq(info.poolCeiling, 10_000e18);

        vm.stopPrank();
    }

    function testSetPriceThresholds_ShouldSetPriceThresholds() public {
        vm.startPrank(admin);

        vm.expectEmit(address(ubiquityPoolFacet));
        emit PriceThresholdsSet(1010000, 990000);
        ubiquityPoolFacet.setPriceThresholds(1010000, 990000);

        vm.stopPrank();
    }

    function testSetRedemptionDelayBlocks_ShouldSetRedemptionDelayInBlocks()
        public
    {
        vm.startPrank(admin);

        vm.expectEmit(address(ubiquityPoolFacet));
        emit RedemptionDelayBlocksSet(2);
        ubiquityPoolFacet.setRedemptionDelayBlocks(2);

        vm.stopPrank();
    }

    function testToggleCollateral_ShouldToggleCollateral() public {
        vm.startPrank(admin);

        LibUbiquityPool.CollateralInformation memory info = ubiquityPoolFacet
            .collateralInformation(address(collateralToken));
        assertEq(info.isEnabled, true);

        vm.expectEmit(address(ubiquityPoolFacet));
        emit CollateralToggled(0, false);
        ubiquityPoolFacet.toggleCollateral(0);

        vm.expectRevert("Invalid collateral");
        info = ubiquityPoolFacet.collateralInformation(
            address(collateralToken)
        );

        vm.stopPrank();
    }

    function testToggleMintRedeemBorrow_ShouldToggleMinting() public {
        vm.startPrank(admin);

        uint256 collateralIndex = 0;
        uint8 toggleIndex = 0;

        LibUbiquityPool.CollateralInformation memory info = ubiquityPoolFacet
            .collateralInformation(address(collateralToken));
        assertEq(info.isMintPaused, false);

        vm.expectEmit(address(ubiquityPoolFacet));
        emit MintRedeemBorrowToggled(collateralIndex, toggleIndex);
        ubiquityPoolFacet.toggleMintRedeemBorrow(collateralIndex, toggleIndex);

        info = ubiquityPoolFacet.collateralInformation(
            address(collateralToken)
        );
        assertEq(info.isMintPaused, true);

        vm.stopPrank();
    }

    function testToggleMintRedeemBorrow_ShouldToggleRedeeming() public {
        vm.startPrank(admin);

        uint256 collateralIndex = 0;
        uint8 toggleIndex = 1;

        LibUbiquityPool.CollateralInformation memory info = ubiquityPoolFacet
            .collateralInformation(address(collateralToken));
        assertEq(info.isRedeemPaused, false);

        vm.expectEmit(address(ubiquityPoolFacet));
        emit MintRedeemBorrowToggled(collateralIndex, toggleIndex);
        ubiquityPoolFacet.toggleMintRedeemBorrow(collateralIndex, toggleIndex);

        info = ubiquityPoolFacet.collateralInformation(
            address(collateralToken)
        );
        assertEq(info.isRedeemPaused, true);

        vm.stopPrank();
    }

    function testToggleMintRedeemBorrow_ShouldToggleBorrowingByAmoMinter()
        public
    {
        vm.startPrank(admin);

        uint256 collateralIndex = 0;
        uint8 toggleIndex = 2;

        LibUbiquityPool.CollateralInformation memory info = ubiquityPoolFacet
            .collateralInformation(address(collateralToken));
        assertEq(info.isBorrowPaused, false);

        vm.expectEmit(address(ubiquityPoolFacet));
        emit MintRedeemBorrowToggled(collateralIndex, toggleIndex);
        ubiquityPoolFacet.toggleMintRedeemBorrow(collateralIndex, toggleIndex);

        info = ubiquityPoolFacet.collateralInformation(
            address(collateralToken)
        );
        assertEq(info.isBorrowPaused, true);

        vm.stopPrank();
    }
}
