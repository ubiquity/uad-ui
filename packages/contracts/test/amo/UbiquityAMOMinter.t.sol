// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {DiamondTestSetup} from "../diamond/DiamondTestSetup.sol";
import {UbiquityAMOMinter} from "../../src/dollar/core/UbiquityAMOMinter.sol";
import {AaveAMO} from "../../src/dollar/amo/AaveAMO.sol";
import {MockERC20} from "../../src/dollar/mocks/MockERC20.sol";
import {IUbiquityPool} from "../../src/dollar/interfaces/IUbiquityPool.sol";
import {MockChainLinkFeed} from "../../src/dollar/mocks/MockChainLinkFeed.sol";

contract UbiquityAMOMinterTest is DiamondTestSetup {
    UbiquityAMOMinter amoMinter;
    AaveAMO aaveAMO;
    MockERC20 collateralToken;
    MockChainLinkFeed collateralTokenPriceFeed;

    address newPoolAddress = address(4); // mock new pool address
    address nonAMO = address(9999);

    function setUp() public override {
        super.setUp();

        // Initialize mock collateral token and price feed
        collateralToken = new MockERC20("Mock Collateral", "MCT", 18);
        collateralTokenPriceFeed = new MockChainLinkFeed();

        // Deploy UbiquityAMOMinter contract
        amoMinter = new UbiquityAMOMinter(
            owner,
            address(collateralToken), // Collateral token address
            0, // Collateral index
            address(ubiquityPoolFacet) // Pool address
        );

        // Deploy AaveAMO contract
        aaveAMO = new AaveAMO(
            owner,
            address(amoMinter),
            address(1),
            address(2),
            address(3),
            address(4)
        );

        // Enable AaveAMO as a valid AMO
        vm.prank(owner);
        amoMinter.enableAMO(address(aaveAMO));

        vm.startPrank(admin); // Prank as admin for pool setup

        // Add collateral token to the pool with a ceiling
        uint256 poolCeiling = 500_000e18;
        ubiquityPoolFacet.addCollateralToken(
            address(collateralToken),
            address(collateralTokenPriceFeed),
            poolCeiling
        );

        // Enable collateral and register AMO Minter
        ubiquityPoolFacet.toggleCollateral(0);
        ubiquityPoolFacet.addAmoMinter(address(amoMinter));

        // Mint collateral to the pool
        collateralToken.mint(address(ubiquityPoolFacet), 500_000e18);

        vm.stopPrank();
    }

    /* ========== Tests for AMO management ========== */

    function testEnableAMO_ShouldWorkWhenCalledByOwner() public {
        // Test enabling a new AMO
        address newAMO = address(10);
        vm.prank(owner);
        amoMinter.enableAMO(newAMO);

        // Check if the new AMO is enabled
        assertEq(amoMinter.AMOs(newAMO), true);
    }

    function testDisableAMO_ShouldWorkWhenCalledByOwner() public {
        // Test disabling the AaveAMO
        vm.prank(owner);
        amoMinter.disableAMO(address(aaveAMO));

        // Check if the AMO is disabled
        assertEq(amoMinter.AMOs(address(aaveAMO)), false);
    }

    function testEnableAMO_ShouldRevertWhenCalledByNonOwner() public {
        // Ensure only the owner can enable AMOs
        address newAMO = address(10);
        vm.prank(nonAMO);
        vm.expectRevert("Ownable: caller is not the owner");
        amoMinter.enableAMO(newAMO);
    }

    function testDisableAMO_ShouldRevertWhenCalledByNonOwner() public {
        // Ensure only the owner can disable AMOs
        vm.prank(nonAMO);
        vm.expectRevert("Ownable: caller is not the owner");
        amoMinter.disableAMO(address(aaveAMO));
    }

    /* ========== Tests for giveCollatToAMO ========== */

    function testGiveCollatToAMO_ShouldWorkWhenCalledByOwner() public {
        uint256 collatAmount = 1000e18;

        // Owner gives collateral to the AaveAMO
        vm.prank(owner);
        amoMinter.giveCollatToAMO(address(aaveAMO), collatAmount);

        // Verify the balances
        assertEq(
            amoMinter.collat_borrowed_balances(address(aaveAMO)),
            int256(collatAmount)
        );
        assertEq(amoMinter.collat_borrowed_sum(), int256(collatAmount));
    }

    function testGiveCollatToAMO_ShouldRevertWhenNotValidAMO() public {
        uint256 collatAmount = 1000e18;

        // Ensure giving collateral to a non-AMO address reverts
        vm.prank(owner);
        vm.expectRevert("Invalid AMO");
        amoMinter.giveCollatToAMO(nonAMO, collatAmount);
    }

    function testGiveCollatToAMO_ShouldRevertWhenExceedingBorrowCap() public {
        uint256 collatAmount = 200000e18; // Exceeds the default borrow cap of 100_000

        // Ensure exceeding the borrow cap reverts
        vm.prank(owner);
        vm.expectRevert("Borrow cap");
        amoMinter.giveCollatToAMO(address(aaveAMO), collatAmount);
    }

    /* ========== Tests for receiveCollatFromAMO ========== */

    // This function is actually intended to be called by the AMO, but we can test it by calling it directly
    function testReceiveCollatFromAMO_ShouldWorkWhenCalledByValidAMO() public {
        uint256 collatAmount = 1000e18;

        uint256 poolBalance = collateralToken.balanceOf(
            address(ubiquityPoolFacet)
        );

        // First, give collateral to the AMO
        vm.prank(owner);
        amoMinter.giveCollatToAMO(address(aaveAMO), collatAmount);

        // AMO returns collateral
        vm.startPrank(address(aaveAMO));
        collateralToken.approve(address(amoMinter), collatAmount);
        amoMinter.receiveCollatFromAMO(collatAmount);
        vm.stopPrank();

        // Verify the balances
        assertEq(amoMinter.collat_borrowed_balances(address(aaveAMO)), 0);
        assertEq(amoMinter.collat_borrowed_sum(), 0);
        assertEq(collateralToken.balanceOf(address(aaveAMO)), 0);
        assertEq(collateralToken.balanceOf(address(amoMinter)), 0);
        assertEq(
            poolBalance,
            collateralToken.balanceOf(address(ubiquityPoolFacet))
        );
    }

    function testReceiveCollatFromAMO_ShouldRevertWhenNotValidAMO() public {
        uint256 collatAmount = 1000e18;

        // Ensure non-AMO cannot return collateral
        vm.prank(nonAMO);
        vm.expectRevert("Invalid AMO");
        amoMinter.receiveCollatFromAMO(collatAmount);
    }

    /* ========== Tests for setCollatBorrowCap ========== */

    function testSetCollatBorrowCap_ShouldWorkWhenCalledByOwner() public {
        uint256 newCap = 5000000e6; // new cap

        // Owner sets new collateral borrow cap
        vm.prank(owner);
        amoMinter.setCollatBorrowCap(newCap);

        // Verify the collateral borrow cap was updated
        assertEq(amoMinter.collat_borrow_cap(), int256(newCap));
    }

    function testSetCollatBorrowCap_ShouldRevertWhenCalledByNonOwner() public {
        uint256 newCap = 5000000e6; // new cap

        // Ensure non-owner cannot set the cap
        vm.prank(address(1234));
        vm.expectRevert("Ownable: caller is not the owner");
        amoMinter.setCollatBorrowCap(newCap);
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
