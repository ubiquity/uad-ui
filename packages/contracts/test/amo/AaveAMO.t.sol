// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {DiamondTestSetup} from "../diamond/DiamondTestSetup.sol";
import {UbiquityAMOMinter} from "../../src/dollar/core/UbiquityAMOMinter.sol";
import {AaveAMO} from "../../src/dollar/amo/AaveAMO.sol";
import {MockERC20} from "../../../../src/dollar/mocks/MockERC20.sol";
import {MockChainLinkFeed} from "../../src/dollar/mocks/MockChainLinkFeed.sol";
import {IPool} from "@aavev3-core/contracts/interfaces/IPool.sol";
import {IAToken} from "@aavev3-core/contracts/interfaces/IAToken.sol";
import {IVariableDebtToken} from "@aavev3-core/contracts/interfaces/IVariableDebtToken.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AaveAMOTest is DiamondTestSetup {
    UbiquityAMOMinter amoMinter;
    AaveAMO aaveAMO;
    address collateralOwner =
        address(0xC959483DBa39aa9E78757139af0e9a2EDEb3f42D); // Aave Sepolia Faucet
    MockERC20 collateralToken =
        MockERC20(0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357); // DAI-TestnetMintableERC20-Aave Sepolia
    MockChainLinkFeed collateralTokenPriceFeed =
        MockChainLinkFeed(0x9aF11c35c5d3Ae182C0050438972aac4376f9516); // DAI-TestnetPriceAggregator-Aave Sepolia
    IAToken aToken = IAToken(0x29598b72eb5CeBd806C5dCD549490FdA35B13cD8); // DAI-AToken-Aave Sepolia
    IVariableDebtToken vToken =
        IVariableDebtToken(0x22675C506A8FC26447aFFfa33640f6af5d4D4cF0); // DAI-VariableDebtToken-Aave Sepolia
    ERC20 AAVE = ERC20(0x88541670E55cC00bEEFD87eB59EDd1b7C511AC9a); // AAVE Token

    // Constants for the test
    address constant newAMOMinterAddress = address(5); // mock new AMO minter address
    address constant nonAMO = address(9999); // Address representing a non-AMO entity
    uint256 constant interestRateMode = 2; // Variable interest rate mode in Aave

    // Mocking the Aave Pool
    IPool private constant aave_pool =
        IPool(0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951); // Aave V3 Sepolia Pool

    function setUp() public override {
        vm.createSelectFork(vm.rpcUrl("sepolia"));
        super.setUp();

        // Deploy UbiquityAMOMinter contract
        amoMinter = new UbiquityAMOMinter(
            owner,
            address(collateralToken),
            0,
            address(ubiquityPoolFacet)
        );

        // Deploy AaveAMO contract
        aaveAMO = new AaveAMO(
            owner,
            address(amoMinter),
            address(aave_pool),
            address(1),
            address(1),
            address(1)
        );

        // Enable AaveAMO as a valid AMO
        vm.prank(owner);
        amoMinter.enableAMO(address(aaveAMO));

        vm.startPrank(admin);

        // Add collateral token to the pool
        uint256 poolCeiling = 500_000e18;
        ubiquityPoolFacet.addCollateralToken(
            address(collateralToken),
            address(collateralTokenPriceFeed),
            poolCeiling
        );

        // Enable collateral and register AMO Minter
        ubiquityPoolFacet.toggleCollateral(0);
        ubiquityPoolFacet.addAmoMinter(address(amoMinter));

        vm.stopPrank();
    }

    /* ========== AAVE AMO COLLATERAL TESTS ========== */

    function testAaveDepositCollateral_ShouldDepositSuccessfully() public {
        uint256 depositAmount = 1000e18;

        // Mints collateral to AMO
        vm.prank(collateralOwner);
        collateralToken.mint(address(aaveAMO), depositAmount);

        // Owner deposits collateral to Aave Pool
        vm.prank(owner);
        aaveAMO.aaveDepositCollateral(address(collateralToken), depositAmount);

        // Check if the deposit was successful
        assertEq(aToken.balanceOf(address(aaveAMO)), depositAmount);
        assertEq(collateralToken.balanceOf(address(aaveAMO)), 0);
    }

    function testAaveWithdrawCollateral_ShouldWithdrawSuccessfully() public {
        uint256 withdrawAmount = 1000e18;

        // Mints collateral to AMO
        vm.prank(collateralOwner);
        collateralToken.mint(address(aaveAMO), withdrawAmount);

        // Owner deposits collateral to Aave Pool
        vm.prank(owner);
        aaveAMO.aaveDepositCollateral(address(collateralToken), withdrawAmount);

        // Check balances before withdrawal
        assertEq(aToken.balanceOf(address(aaveAMO)), withdrawAmount);
        assertEq(collateralToken.balanceOf(address(aaveAMO)), 0);

        // Owner withdraws collateral from Aave Pool
        vm.prank(owner);
        aaveAMO.aaveWithdrawCollateral(
            address(collateralToken),
            withdrawAmount
        );
        assertEq(aToken.balanceOf(address(aaveAMO)), 0);
        assertEq(collateralToken.balanceOf(address(aaveAMO)), withdrawAmount);
    }

    /* ========== AAVE AMO BORROW AND REPAY TESTS ========== */

    function testAaveBorrow_ShouldBorrowAssetSuccessfully() public {
        uint256 depositAmount = 1000e18;

        // Mints collateral to AMO
        vm.prank(collateralOwner);
        collateralToken.mint(address(aaveAMO), depositAmount);

        // Owner deposits collateral to Aave Pool
        vm.prank(owner);
        aaveAMO.aaveDepositCollateral(address(collateralToken), depositAmount);

        // Check balances before withdrawal
        assertEq(aToken.balanceOf(address(aaveAMO)), depositAmount);
        assertEq(collateralToken.balanceOf(address(aaveAMO)), 0);

        uint256 borrowAmount = 1e18;

        // Owner borrows asset from Aave Pool
        vm.prank(owner);
        aaveAMO.aaveBorrow(
            address(collateralToken),
            borrowAmount,
            interestRateMode
        );

        // Check if the borrow was successful
        assertEq(collateralToken.balanceOf(address(aaveAMO)), borrowAmount);
        assertEq(vToken.scaledBalanceOf(address(aaveAMO)), borrowAmount);
    }

    function testAaveRepay_ShouldRepayAssetSuccessfully() public {
        uint256 depositAmount = 1000e18;

        // Mints collateral to AMO
        vm.prank(collateralOwner);
        collateralToken.mint(address(aaveAMO), depositAmount);

        // Owner deposits collateral to Aave Pool
        vm.prank(owner);
        aaveAMO.aaveDepositCollateral(address(collateralToken), depositAmount);

        // Check balances before withdrawal
        assertEq(aToken.balanceOf(address(aaveAMO)), depositAmount);
        assertEq(collateralToken.balanceOf(address(aaveAMO)), 0);

        uint256 borrowAmount = 1e18;

        // Owner borrows asset from Aave Pool
        vm.prank(owner);
        aaveAMO.aaveBorrow(
            address(collateralToken),
            borrowAmount,
            interestRateMode
        );

        // Check if the borrow was successful
        assertEq(collateralToken.balanceOf(address(aaveAMO)), borrowAmount);
        assertEq(vToken.scaledBalanceOf(address(aaveAMO)), borrowAmount);

        // Owner repays asset to Aave Pool
        vm.prank(owner);
        aaveAMO.aaveRepay(
            address(collateralToken),
            borrowAmount,
            interestRateMode
        );

        // Check if the repayment was successful
        assertEq(collateralToken.balanceOf(address(aaveAMO)), 0);
        assertEq(vToken.scaledBalanceOf(address(aaveAMO)), 0);
    }

    function testAaveDeposit_ShouldRevertIfNotOwner() public {
        uint256 depositAmount = 1e18;

        // Attempting to deposit as a non-owner should revert
        vm.prank(nonAMO);
        vm.expectRevert("Ownable: caller is not the owner");
        aaveAMO.aaveDepositCollateral(address(collateralToken), depositAmount);
    }

    function testAaveWithdraw_ShouldRevertIfNotOwner() public {
        uint256 withdrawAmount = 1e18;

        // Attempting to withdraw as a non-owner should revert
        vm.prank(nonAMO);
        vm.expectRevert("Ownable: caller is not the owner");
        aaveAMO.aaveWithdrawCollateral(
            address(collateralToken),
            withdrawAmount
        );
    }

    function testAaveBorrow_ShouldRevertIfNotOwner() public {
        uint256 borrowAmount = 1e18;

        // Attempting to repay as a non-owner should revert
        vm.prank(nonAMO);
        vm.expectRevert("Ownable: caller is not the owner");
        aaveAMO.aaveBorrow(
            address(collateralToken),
            borrowAmount,
            interestRateMode
        );
    }

    function testAaveRepay_ShouldRevertIfNotOwner() public {
        uint256 borrowAmount = 1e18;

        // Attempting to repay as a non-owner should revert
        vm.prank(nonAMO);
        vm.expectRevert("Ownable: caller is not the owner");
        aaveAMO.aaveRepay(
            address(collateralToken),
            borrowAmount,
            interestRateMode
        );
    }

    /* ========== AAVE AMO MINTER TESTS ========== */

    function testReturnCollateralToMinter_ShouldWork() public {
        uint256 returnAmount = 1000e18;

        // Mints collateral to AMO
        vm.prank(collateralOwner);
        collateralToken.mint(address(aaveAMO), returnAmount);

        // Owner returns collateral to the AMO Minter
        vm.prank(owner);
        aaveAMO.returnCollateralToMinter(returnAmount);

        // Verify pool received collateral
        assertEq(
            collateralToken.balanceOf(address(ubiquityPoolFacet)),
            returnAmount
        );
    }

    function testReturnCollateralToMinter_ShouldRevertIfNotOwner() public {
        uint256 returnAmount = 1000e18;

        // Revert if a non-owner tries to return collateral
        vm.prank(nonAMO);
        vm.expectRevert("Ownable: caller is not the owner");
        aaveAMO.returnCollateralToMinter(returnAmount);
    }

    function testSetAMOMinter_ShouldWorkWhenCalledByOwner() public {
        // Set new AMO minter address
        vm.prank(owner);
        aaveAMO.setAMOMinter(newAMOMinterAddress);

        // Verify the new AMO minter address was set
        assertEq(address(aaveAMO.amo_minter()), newAMOMinterAddress);
    }

    function testSetAMOMinter_ShouldRevertIfNotOwner() public {
        // Attempting to set a new AMO minter address as a non-owner should revert
        vm.prank(nonAMO);
        vm.expectRevert("Ownable: caller is not the owner");
        aaveAMO.setAMOMinter(newAMOMinterAddress);
    }

    /* ========== AAVE AMO EMERGENCY TESTS ========== */

    function testRecoverERC20_ShouldTransferERC20ToOwner() public {
        uint256 tokenAmount = 1000e18;

        // Mint some tokens to AaveAMO
        MockERC20 mockToken = new MockERC20("Mock Token", "MTK", 18);
        mockToken.mint(address(aaveAMO), tokenAmount);

        // Recover tokens as the owner
        vm.prank(owner);
        aaveAMO.recoverERC20(address(mockToken), tokenAmount);

        // Check if the tokens were transferred to the owner
        assertEq(mockToken.balanceOf(owner), tokenAmount);
    }

    function testRecoverERC20_ShouldRevertIfNotOwner() public {
        uint256 tokenAmount = 1000e18;

        // Revert if non-owner attempts to recover tokens
        vm.prank(nonAMO);
        vm.expectRevert("Ownable: caller is not the owner");
        aaveAMO.recoverERC20(address(collateralToken), tokenAmount);
    }

    function testExecute_ShouldExecuteCallSuccessfully() public {
        // Example of executing a simple call
        vm.prank(owner);
        (bool success, ) = aaveAMO.execute(owner, 0, "");

        // Verify the call executed successfully
        assertTrue(success);
    }

    function testExecute_ShouldRevertIfNotOwner() public {
        // Attempting to call execute as a non-owner should revert
        vm.prank(nonAMO);
        vm.expectRevert("Ownable: caller is not the owner");
        aaveAMO.execute(owner, 0, "");
    }
}
