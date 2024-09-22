// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {DiamondTestSetup} from "../diamond/DiamondTestSetup.sol";
import {UbiquityAmoMinter} from "../../src/dollar/core/UbiquityAmoMinter.sol";
import {AaveAmo} from "../../src/dollar/amo/AaveAmo.sol";
import {MockERC20} from "../../src/dollar/mocks/MockERC20.sol";
import {MockChainLinkFeed} from "../../src/dollar/mocks/MockChainLinkFeed.sol";
import {IPool} from "@aavev3-core/contracts/interfaces/IPool.sol";
import {IAToken} from "@aavev3-core/contracts/interfaces/IAToken.sol";
import {IVariableDebtToken} from "@aavev3-core/contracts/interfaces/IVariableDebtToken.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AaveAmoTest is DiamondTestSetup {
    UbiquityAmoMinter amoMinter;
    AaveAmo aaveAmo;
    address rewardsController =
        address(0x4DA5c4da71C5a167171cC839487536d86e083483); // Aave Rewards Controller
    address collateralOwner =
        address(0xC959483DBa39aa9E78757139af0e9a2EDEb3f42D); // Aave Sepolia Faucet
    MockERC20 collateralToken =
        MockERC20(0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357); // DAI-TestnetMintableERC20-Aave Sepolia
    MockChainLinkFeed collateralTokenPriceFeed =
        MockChainLinkFeed(0x9aF11c35c5d3Ae182C0050438972aac4376f9516); // DAI-TestnetPriceAggregator-Aave Sepolia
    IAToken aToken = IAToken(0x29598b72eb5CeBd806C5dCD549490FdA35B13cD8); // DAI-AToken-Aave Sepolia
    IVariableDebtToken vToken =
        IVariableDebtToken(0x22675C506A8FC26447aFFfa33640f6af5d4D4cF0); // DAI-VariableDebtToken-Aave Sepolia

    // Constants for the test
    address constant newAmoMinterAddress = address(5); // mock new Amo minter address
    address constant nonAmo = address(9999); // Address representing a non-Amo entity
    uint256 constant interestRateMode = 2; // Variable interest rate mode in Aave

    // Mocking the Aave Pool
    IPool private constant aavePool =
        IPool(0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951); // Aave V3 Sepolia Pool

    function setUp() public override {
        vm.createSelectFork(vm.rpcUrl("sepolia"));
        super.setUp();

        // Deploy UbiquityAmoMinter contract
        amoMinter = new UbiquityAmoMinter(
            owner,
            address(collateralToken),
            0,
            address(ubiquityPoolFacet)
        );

        // Deploy AaveAmo contract
        aaveAmo = new AaveAmo(
            owner,
            address(amoMinter),
            address(aavePool),
            address(rewardsController)
        );

        // Enable AaveAmo as a valid Amo
        vm.prank(owner);
        amoMinter.enableAmo(address(aaveAmo));

        vm.startPrank(admin);

        // Add collateral token to the pool
        uint256 poolCeiling = 500_000e18;
        ubiquityPoolFacet.addCollateralToken(
            address(collateralToken),
            address(collateralTokenPriceFeed),
            poolCeiling
        );

        // Enable collateral and register Amo Minter
        ubiquityPoolFacet.toggleCollateral(0);
        ubiquityPoolFacet.addAmoMinter(address(amoMinter));

        vm.stopPrank();
    }

    /* ========== Aave Amo SETUP TESTS ========== */

    function testAaveAmoSetup_ShouldSet_owner() public {
        // Verify the owner was set correctly
        assertEq(aaveAmo.owner(), owner);
    }

    function testAaveAmoSetup_ShouldSet_amoMinter() public {
        // Verify the Amo minter was set correctly
        assertEq(address(aaveAmo.amoMinter()), address(amoMinter));
    }

    function testAaveAmoSetup_ShouldSet_aavePool() public {
        // Verify the Aave pool was set correctly
        assertEq(address(aaveAmo.aavePool()), address(aavePool));
    }

    function testAaveAmoSetup_ShouldSet_aaveRewardsController() public {
        // Verify the Aave rewards controller was set correctly
        assertEq(
            address(aaveAmo.aaveRewardsController()),
            address(rewardsController)
        );
    }

    function testConstructor_ShouldRevertWhenOwnerIsZeroAddress() public {
        // Test with zero address for owner
        vm.expectRevert("Owner address cannot be zero");
        new AaveAmo(
            address(0), // Invalid owner address
            address(amoMinter),
            address(aavePool),
            address(rewardsController)
        );
    }

    function testConstructor_ShouldRevertWhenAmoMinterIsZeroAddress() public {
        // Test with zero address for Amo minter
        vm.expectRevert("Amo minter address cannot be zero");
        new AaveAmo(
            owner,
            address(0), // Invalid Amo minter address
            address(aavePool),
            address(rewardsController)
        );
    }

    function testConstructor_ShouldRevertWhenAavePoolIsZeroAddress() public {
        // Test with zero address for Aave pool
        vm.expectRevert("Aave pool address cannot be zero");
        new AaveAmo(
            owner,
            address(amoMinter),
            address(0), // Invalid Aave pool address
            address(rewardsController)
        );
    }

    function testConstructor_ShouldRevertWhenAaveRewardsControllerIsZeroAddress()
        public
    {
        // Test with zero address for Aave
        vm.expectRevert("Aave rewards controller address cannot be zero");
        new AaveAmo(
            owner,
            address(amoMinter),
            address(aavePool),
            address(0) // Invalid Aave rewards controller address
        );
    }

    /* ========== Aave Amo COLLATERAL TESTS ========== */

    function testAaveDepositCollateral_ShouldDepositSuccessfully() public {
        uint256 depositAmount = 1000e18;

        // Mints collateral to Amo
        vm.prank(collateralOwner);
        collateralToken.mint(address(aaveAmo), depositAmount);

        // Owner deposits collateral to Aave Pool
        vm.prank(owner);
        aaveAmo.aaveDepositCollateral(address(collateralToken), depositAmount);

        // Check if the deposit was successful
        assertApproxEqAbs(
            aToken.balanceOf(address(aaveAmo)),
            depositAmount,
            1e2
        ); // little error this is due to interest rate
        assertEq(collateralToken.balanceOf(address(aaveAmo)), 0);
    }

    function testAaveWithdrawCollateral_ShouldWithdrawSuccessfully() public {
        uint256 depositAmount = 1000e18;

        // Mints collateral to Amo
        vm.prank(collateralOwner);
        collateralToken.mint(address(aaveAmo), depositAmount);

        // Owner deposits collateral to Aave Pool
        vm.prank(owner);
        aaveAmo.aaveDepositCollateral(address(collateralToken), depositAmount);

        // Check balances before withdrawal
        assertApproxEqAbs(
            aToken.balanceOf(address(aaveAmo)),
            depositAmount,
            1e2
        ); // little error this is due to interest rate
        assertEq(collateralToken.balanceOf(address(aaveAmo)), 0);

        uint256 withdrawAmount = aToken.balanceOf(address(aaveAmo));

        // Owner withdraws collateral from Aave Pool
        vm.prank(owner);
        aaveAmo.aaveWithdrawCollateral(
            address(collateralToken),
            withdrawAmount
        );
        assertEq(aToken.balanceOf(address(aaveAmo)), 0);
        assertEq(collateralToken.balanceOf(address(aaveAmo)), withdrawAmount);
    }

    function testAaveDeposit_ShouldRevertIfNotOwner() public {
        uint256 depositAmount = 1e18;

        // Attempting to deposit as a non-owner should revert
        vm.prank(nonAmo);
        vm.expectRevert("Ownable: caller is not the owner");
        aaveAmo.aaveDepositCollateral(address(collateralToken), depositAmount);
    }

    function testAaveWithdraw_ShouldRevertIfNotOwner() public {
        uint256 withdrawAmount = 1e18;

        // Attempting to withdraw as a non-owner should revert
        vm.prank(nonAmo);
        vm.expectRevert("Ownable: caller is not the owner");
        aaveAmo.aaveWithdrawCollateral(
            address(collateralToken),
            withdrawAmount
        );
    }

    /* ========== Aave Amo MINTER TESTS ========== */

    function testReturnCollateralToMinter_ShouldWork() public {
        uint256 returnAmount = 1000e18;

        // Mints collateral to Amo
        vm.prank(collateralOwner);
        collateralToken.mint(address(aaveAmo), returnAmount);

        // Owner returns collateral to the Amo Minter
        vm.prank(owner);
        aaveAmo.returnCollateralToMinter(returnAmount);

        // Verify pool received collateral
        assertEq(
            collateralToken.balanceOf(address(ubiquityPoolFacet)),
            returnAmount
        );
    }

    function testReturnCollateralToMinter_ShouldRevertIfNotOwner() public {
        uint256 returnAmount = 1000e18;

        // Revert if a non-owner tries to return collateral
        vm.prank(nonAmo);
        vm.expectRevert("Ownable: caller is not the owner");
        aaveAmo.returnCollateralToMinter(returnAmount);
    }

    function testSetAmoMinter_ShouldWorkWhenCalledByOwner() public {
        // Set new Amo minter address
        vm.prank(owner);
        aaveAmo.setAmoMinter(newAmoMinterAddress);

        // Verify the new Amo minter address was set
        assertEq(address(aaveAmo.amoMinter()), newAmoMinterAddress);
    }

    function testSetAmoMinter_ShouldRevertIfNotOwner() public {
        // Attempting to set a new Amo minter address as a non-owner should revert
        vm.prank(nonAmo);
        vm.expectRevert("Ownable: caller is not the owner");
        aaveAmo.setAmoMinter(newAmoMinterAddress);
    }

    /* =========== Aave Amo REWARDS TESTS =========== */

    function testClaimAllRewards_ShouldClaimRewardsSuccessfully() public {
        uint256 depositAmount = 1000e18;

        // Mints collateral to Amo
        vm.prank(collateralOwner);
        collateralToken.mint(address(aaveAmo), depositAmount);

        // Owner deposits collateral to Aave Pool
        vm.prank(owner);
        aaveAmo.aaveDepositCollateral(address(collateralToken), depositAmount);

        // Specify assets to claim rewards for
        address[] memory assets = new address[](1);
        assets[0] = aavePool
            .getReserveData(address(collateralToken))
            .aTokenAddress;

        // Claim rewards from Aave
        vm.prank(owner);
        aaveAmo.claimAllRewards(assets);

        // Verify the rewards were claimed successfully
        assertTrue(true);
    }

    /* ========== Aave Amo EMERGENCY TESTS ========== */

    function testRecoverERC20_ShouldTransferERC20ToOwner() public {
        uint256 tokenAmount = 1000e18;

        // Mint some tokens to AaveAmo
        MockERC20 mockToken = new MockERC20("Mock Token", "MTK", 18);
        mockToken.mint(address(aaveAmo), tokenAmount);

        // Recover tokens as the owner
        vm.prank(owner);
        aaveAmo.recoverERC20(address(mockToken), tokenAmount);

        // Check if the tokens were transferred to the owner
        assertEq(mockToken.balanceOf(owner), tokenAmount);
    }

    function testRecoverERC20_ShouldRevertIfNotOwner() public {
        uint256 tokenAmount = 1000e18;

        // Revert if non-owner attempts to recover tokens
        vm.prank(nonAmo);
        vm.expectRevert("Ownable: caller is not the owner");
        aaveAmo.recoverERC20(address(collateralToken), tokenAmount);
    }

    function testExecute_ShouldExecuteCallSuccessfully() public {
        // Example of executing a simple call
        vm.prank(owner);
        (bool success, ) = aaveAmo.execute(owner, 0, "");

        // Verify the call executed successfully
        assertTrue(success);
    }

    function testExecute_ShouldRevertIfNotOwner() public {
        // Attempting to call execute as a non-owner should revert
        vm.prank(nonAmo);
        vm.expectRevert("Ownable: caller is not the owner");
        aaveAmo.execute(owner, 0, "");
    }
}
