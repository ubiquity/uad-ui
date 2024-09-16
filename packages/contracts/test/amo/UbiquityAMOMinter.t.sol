// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {DiamondTestSetup} from "../diamond/DiamondTestSetup.sol";
import {UbiquityAMOMinter} from "../../src/dollar/core/UbiquityAMOMinter.sol";
import {MockERC20} from "../../../../src/dollar/mocks/MockERC20.sol";
import {IUbiquityPool} from "../../src/dollar/interfaces/IUbiquityPool.sol";

contract UbiquityAMOMinterTest is DiamondTestSetup {
    UbiquityAMOMinter amoMinter;
    MockERC20 collateralToken;
    IUbiquityPool mockPool;

    address timelock = address(2); // mock timelock
    address poolAddress = address(3); // mock pool
    address collateralAddress = address(4); // mock collateral token

    function setUp() public override {
        super.setUp();

        collateralToken = new MockERC20("Mock Collateral", "MCT", 18);
        mockPool = IUbiquityPool(poolAddress);

        // Deploy UbiquityAMOMinter contract
        amoMinter = new UbiquityAMOMinter(
            owner, // Owner address
            timelock, // Timelock address
            address(collateralToken), // Collateral token address
            address(mockPool) // Pool address
        );
    }

    function testConstructor_ShouldWork() public {
        // Verify that the constructor initializes the parameters correctly
        assertEq(amoMinter.owner(), owner);
        assertEq(amoMinter.timelock_address(), timelock);
        assertEq(
            address(amoMinter.collateral_token()),
            address(collateralToken)
        );
        assertEq(amoMinter.missing_decimals(), 0); // Collateral token has 18 decimals, so missing decimals is 0
        assertEq(address(amoMinter.pool()), address(mockPool));
    }

    function testConstructor_ShouldRevertWhenOwnerIsZero() public {
        // Ensure constructor reverts with address(0) for owner
        vm.expectRevert("Owner address cannot be zero");
        new UbiquityAMOMinter(
            address(0),
            timelock,
            collateralAddress,
            poolAddress
        );
    }

    function testConstructor_ShouldRevertWhenTimelockIsZero() public {
        // Ensure constructor reverts with address(0) for timelock
        vm.expectRevert("Timelock address cannot be zero");
        new UbiquityAMOMinter(
            owner,
            address(0),
            collateralAddress,
            poolAddress
        );
    }

    function testConstructor_ShouldRevertWhenPoolIsZero() public {
        // Ensure constructor reverts with address(0) for pool
        vm.expectRevert("Pool address cannot be zero");
        new UbiquityAMOMinter(owner, timelock, collateralAddress, address(0));
    }
}
