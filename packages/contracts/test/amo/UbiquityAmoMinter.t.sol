// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {DiamondTestSetup} from "../diamond/DiamondTestSetup.sol";
import {UbiquityAmoMinter} from "../../src/dollar/core/UbiquityAmoMinter.sol";
import {AaveAmo} from "../../src/dollar/amo/AaveAmo.sol";
import {MockERC20} from "../../src/dollar/mocks/MockERC20.sol";
import {IUbiquityPool} from "../../src/dollar/interfaces/IUbiquityPool.sol";
import {MockChainLinkFeed} from "../../src/dollar/mocks/MockChainLinkFeed.sol";

contract UbiquityAmoMinterTest is DiamondTestSetup {
    UbiquityAmoMinter amoMinter;
    AaveAmo aaveAmo;
    MockERC20 collateralToken;
    MockChainLinkFeed collateralTokenPriceFeed;

    address newPoolAddress = address(4); // mock new pool address
    address nonAmo = address(9999);

    function setUp() public override {
        super.setUp();

        // Initialize mock collateral token and price feed
        collateralToken = new MockERC20("Mock Collateral", "MCT", 18);
        collateralTokenPriceFeed = new MockChainLinkFeed();

        // Deploy UbiquityAmoMinter contract
        amoMinter = new UbiquityAmoMinter(
            owner,
            address(collateralToken), // Collateral token address
            0, // Collateral index
            address(ubiquityPoolFacet) // Pool address
        );

        // Deploy AaveAmo contract
        aaveAmo = new AaveAmo(
            owner,
            address(amoMinter),
            address(1),
            address(2),
            address(3),
            address(4)
        );

        // Enable AaveAmo as a valid Amo
        vm.prank(owner);
        amoMinter.enableAmo(address(aaveAmo));

        vm.startPrank(admin); // Prank as admin for pool setup

        // Add collateral token to the pool with a ceiling
        uint256 poolCeiling = 500_000e18;
        ubiquityPoolFacet.addCollateralToken(
            address(collateralToken),
            address(collateralTokenPriceFeed),
            poolCeiling
        );

        // Enable collateral and register Amo Minter
        ubiquityPoolFacet.toggleCollateral(0);
        ubiquityPoolFacet.addAmoMinter(address(amoMinter));

        // Mint collateral to the pool
        collateralToken.mint(address(ubiquityPoolFacet), 500_000e18);

        vm.stopPrank();
    }

    function testConstructor_ShouldInitializeCorrectly() public {
        // Deploy a new instance of the UbiquityAmoMinter contract
        UbiquityAmoMinter newAmoMinter = new UbiquityAmoMinter(
            owner,
            address(collateralToken), // Collateral token address
            0, // Collateral index
            address(ubiquityPoolFacet) // Pool address
        );

        // Verify the owner is set correctly
        assertEq(newAmoMinter.owner(), owner);

        // Verify the collateral token is set correctly
        assertEq(
            address(newAmoMinter.collateralToken()),
            address(collateralToken)
        );

        // Verify the collateral index is set correctly
        assertEq(newAmoMinter.collateralIndex(), 0);

        // Verify the pool address is set correctly
        assertEq(address(newAmoMinter.pool()), address(ubiquityPoolFacet));

        // Verify the missing decimals calculation
        assertEq(
            newAmoMinter.missingDecimals(),
            uint256(18) - collateralToken.decimals()
        );
    }

    function testConstructor_ShouldRevertIfOwnerIsZero() public {
        // Ensure the constructor reverts if the owner address is zero
        vm.expectRevert("Owner address cannot be zero");
        new UbiquityAmoMinter(
            address(0),
            address(collateralToken), // Collateral token address
            0, // Collateral index
            address(ubiquityPoolFacet) // Pool address
        );
    }

    function testConstructor_ShouldRevertIfPoolAddressIsZero() public {
        // Ensure the constructor reverts if the pool address is zero
        vm.expectRevert("Pool address cannot be zero");
        new UbiquityAmoMinter(
            owner,
            address(collateralToken), // Collateral token address
            0, // Collateral index
            address(0) // Pool address
        );
    }

    /* ========== Tests for Amo management ========== */

    function testEnableAmo_ShouldWorkWhenCalledByOwner() public {
        // Test enabling a new Amo
        address newAmo = address(10);
        vm.prank(owner);
        amoMinter.enableAmo(newAmo);

        // Check if the new Amo is enabled
        assertEq(amoMinter.Amos(newAmo), true);
    }

    function testDisableAmo_ShouldWorkWhenCalledByOwner() public {
        // Test disabling the AaveAmo
        vm.prank(owner);
        amoMinter.disableAmo(address(aaveAmo));

        // Check if the Amo is disabled
        assertEq(amoMinter.Amos(address(aaveAmo)), false);
    }

    function testEnableAmo_ShouldRevertWhenCalledByNonOwner() public {
        // Ensure only the owner can enable Amos
        address newAmo = address(10);
        vm.prank(nonAmo);
        vm.expectRevert("Ownable: caller is not the owner");
        amoMinter.enableAmo(newAmo);
    }

    function testDisableAmo_ShouldRevertWhenCalledByNonOwner() public {
        // Ensure only the owner can disable Amos
        vm.prank(nonAmo);
        vm.expectRevert("Ownable: caller is not the owner");
        amoMinter.disableAmo(address(aaveAmo));
    }

    /* ========== Tests for giveCollateralToAmo ========== */

    function testGiveCollatToAmo_ShouldWorkWhenCalledByOwner() public {
        uint256 collatAmount = 1000e18;

        // Owner gives collateral to the AaveAmo
        vm.prank(owner);
        amoMinter.giveCollateralToAmo(address(aaveAmo), collatAmount);

        // Verify the balances
        assertEq(
            amoMinter.collateralBorrowedBalances(address(aaveAmo)),
            int256(collatAmount)
        );
        assertEq(
            amoMinter.collateralTotalBorrowedBalance(),
            int256(collatAmount)
        );
    }

    function testGiveCollatToAmo_ShouldRevertWhenNotValidAmo() public {
        uint256 collatAmount = 1000e18;

        // Ensure giving collateral to a non-Amo address reverts
        vm.prank(owner);
        vm.expectRevert("Invalid Amo");
        amoMinter.giveCollateralToAmo(nonAmo, collatAmount);
    }

    function testGiveCollatToAmo_ShouldRevertWhenExceedingBorrowCap() public {
        uint256 collatAmount = 200000e18; // Exceeds the default borrow cap of 100_000

        // Ensure exceeding the borrow cap reverts
        vm.prank(owner);
        vm.expectRevert("Borrow cap exceeded");
        amoMinter.giveCollateralToAmo(address(aaveAmo), collatAmount);
    }

    /* ========== Tests for receiveCollateralFromAmo ========== */

    // This function is actually intended to be called by the Amo, but we can test it by calling it directly
    function testReceiveCollatFromAmo_ShouldWorkWhenCalledByValidAmo() public {
        uint256 collatAmount = 1000e18;

        uint256 poolBalance = collateralToken.balanceOf(
            address(ubiquityPoolFacet)
        );

        // First, give collateral to the Amo
        vm.prank(owner);
        amoMinter.giveCollateralToAmo(address(aaveAmo), collatAmount);

        // Amo returns collateral
        vm.startPrank(address(aaveAmo));
        collateralToken.approve(address(amoMinter), collatAmount);
        amoMinter.receiveCollateralFromAmo(collatAmount);
        vm.stopPrank();

        // Verify the balances
        assertEq(amoMinter.collateralBorrowedBalances(address(aaveAmo)), 0);
        assertEq(amoMinter.collateralTotalBorrowedBalance(), 0);
        assertEq(collateralToken.balanceOf(address(aaveAmo)), 0);
        assertEq(collateralToken.balanceOf(address(amoMinter)), 0);
        assertEq(
            poolBalance,
            collateralToken.balanceOf(address(ubiquityPoolFacet))
        );
    }

    function testReceiveCollatFromAmo_ShouldRevertWhenNotValidAmo() public {
        uint256 collatAmount = 1000e18;

        // Ensure non-Amo cannot return collateral
        vm.prank(nonAmo);
        vm.expectRevert("Invalid Amo");
        amoMinter.receiveCollateralFromAmo(collatAmount);
    }

    /* ========== Tests for setCollateralBorrowCap ========== */

    function testSetCollatBorrowCap_ShouldWorkWhenCalledByOwner() public {
        uint256 newCap = 5000000e6; // new cap

        // Owner sets new collateral borrow cap
        vm.prank(owner);
        amoMinter.setCollateralBorrowCap(newCap);

        // Verify the collateral borrow cap was updated
        assertEq(amoMinter.collateralBorrowCap(), int256(newCap));
    }

    function testSetCollatBorrowCap_ShouldRevertWhenCalledByNonOwner() public {
        uint256 newCap = 5000000e6; // new cap

        // Ensure non-owner cannot set the cap
        vm.prank(address(1234));
        vm.expectRevert("Ownable: caller is not the owner");
        amoMinter.setCollateralBorrowCap(newCap);
    }

    /* ========== Tests for setPool ========== */

    function testSetPool_ShouldWorkWhenCalledByOwner() public {
        // Owner sets new pool
        vm.prank(owner);
        amoMinter.setPool(newPoolAddress);

        // Verify the pool address was updated
        assertEq(address(amoMinter.pool()), newPoolAddress);
    }

    function testSetPool_ShouldRevertWhenCalledByNonOwner() public {
        // Ensure non-owner cannot set the pool
        vm.prank(address(1234));
        vm.expectRevert("Ownable: caller is not the owner");
        amoMinter.setPool(newPoolAddress);
    }
}
