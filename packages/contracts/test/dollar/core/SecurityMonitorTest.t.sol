// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "../../../src/dollar/facets/SecurityMonitorFacet.sol";

import "../../../src/dollar/libraries/LibDiamond.sol";

import "../../../src/dollar/Diamond.sol";

import "../../../src/dollar/facets/DiamondCutFacet.sol";

import "../../../src/dollar/facets/DiamondLoupeFacet.sol";

import "../../../src/dollar/facets/OwnershipFacet.sol";

import "../../../src/dollar/mocks/MockFacet.sol";

import "../../../src/dollar/mocks/MockTelegramNotifier.sol";

contract SecurityMonitorFacetTest is Test {
    Diamond public diamond;

    SecurityMonitorFacet public securityMonitor;

    MockFacetWithStorageWriteFunctions public mockFacet;

    MockTelegramNotifier public mockTelegramNotifier;

    address public owner;

    uint256 public constant CHECK_INTERVAL = 1 hours;

    event SecurityIncident(string message);

    function setUp() public {
        owner = address(this);

        // Deploy facets

        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();

        DiamondLoupeFacet diamondLoupeFacet = new DiamondLoupeFacet();

        OwnershipFacet ownershipFacet = new OwnershipFacet();

        securityMonitor = new SecurityMonitorFacet();

        // Prepare initial facet cuts

        IDiamondCut.FacetCut[]
            memory diamondCutFacets = new IDiamondCut.FacetCut[](3);

        diamondCutFacets[0] = IDiamondCut.FacetCut({
            facetAddress: address(diamondCutFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getDiamondCutFacetSelectors()
        });

        diamondCutFacets[1] = IDiamondCut.FacetCut({
            facetAddress: address(diamondLoupeFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getDiamondLoupeFacetSelectors()
        });

        diamondCutFacets[2] = IDiamondCut.FacetCut({
            facetAddress: address(ownershipFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getOwnershipFacetSelectors()
        });

        // Deploy Diamond

        DiamondArgs memory args = DiamondArgs({
            owner: owner,
            init: address(0),
            initCalldata: ""
        });

        diamond = new Diamond(args, diamondCutFacets);

        // Add SecurityMonitorFacet to Diamond

        IDiamondCut.FacetCut[]
            memory securityMonitorCut = new IDiamondCut.FacetCut[](1);

        securityMonitorCut[0] = IDiamondCut.FacetCut({
            facetAddress: address(securityMonitor),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSecurityMonitorFacetSelectors()
        });

        DiamondCutFacet(address(diamond)).diamondCut(
            securityMonitorCut,
            address(0),
            ""
        );

        // Initialize SecurityMonitorFacet

        SecurityMonitorFacet(address(diamond)).initialize(CHECK_INTERVAL);

        // Deploy mocks

        mockFacet = new MockFacetWithStorageWriteFunctions();

        mockTelegramNotifier = new MockTelegramNotifier();

        // Setup mock calls

        vm.mockCall(
            address(diamond),
            abi.encodeWithSignature("hasRole(bytes32,address)"),
            abi.encode(true)
        );

        vm.mockCall(
            address(diamond),
            abi.encodeWithSignature("pauseDollarToken()"),
            abi.encode()
        );
    }

    function testInitialization() public {
        (bool upkeepNeeded, ) = SecurityMonitorFacet(address(diamond))
            .checkUpkeep("");

        assertFalse(upkeepNeeded);

        vm.warp(block.timestamp + CHECK_INTERVAL - 1);

        (upkeepNeeded, ) = SecurityMonitorFacet(address(diamond)).checkUpkeep(
            ""
        );

        assertFalse(upkeepNeeded);

        vm.warp(block.timestamp + 1);

        (upkeepNeeded, ) = SecurityMonitorFacet(address(diamond)).checkUpkeep(
            ""
        );

        assertTrue(upkeepNeeded);
    }

    function testSetCheckInterval() public {
        uint256 newInterval = 2 hours;

        SecurityMonitorFacet(address(diamond)).setCheckInterval(newInterval);

        (bool upkeepNeeded, ) = SecurityMonitorFacet(address(diamond))
            .checkUpkeep("");

        assertFalse(upkeepNeeded);

        vm.warp(block.timestamp + newInterval - 1);

        (upkeepNeeded, ) = SecurityMonitorFacet(address(diamond)).checkUpkeep(
            ""
        );

        assertFalse(upkeepNeeded);

        vm.warp(block.timestamp + 1);

        (upkeepNeeded, ) = SecurityMonitorFacet(address(diamond)).checkUpkeep(
            ""
        );

        assertTrue(upkeepNeeded);
    }

    function testSetCheckInterval_OnlyOwner() public {
        uint256 newInterval = 2 hours;

        // This should succeed

        SecurityMonitorFacet(address(diamond)).setCheckInterval(newInterval);

        // This should fail

        vm.prank(address(0x123)); // Random address

        vm.expectRevert("LibDiamond: Must be contract owner");

        SecurityMonitorFacet(address(diamond)).setCheckInterval(newInterval);
    }

    function getDiamondCutFacetSelectors()
        internal
        pure
        returns (bytes4[] memory selectors)
    {
        selectors = new bytes4[](1); // Initialize array with 1 element

        selectors[0] = DiamondCutFacet.diamondCut.selector;

        return selectors;
    }

    function getDiamondLoupeFacetSelectors()
        internal
        pure
        returns (bytes4[] memory selectors)
    {
        selectors = new bytes4[](5); // Initialize array with 5 elements

        selectors[0] = DiamondLoupeFacet.facets.selector;

        selectors[1] = DiamondLoupeFacet.facetFunctionSelectors.selector;

        selectors[2] = DiamondLoupeFacet.facetAddresses.selector;

        selectors[3] = DiamondLoupeFacet.facetAddress.selector;

        selectors[4] = DiamondLoupeFacet.supportsInterface.selector;

        return selectors;
    }

    function getOwnershipFacetSelectors()
        internal
        pure
        returns (bytes4[] memory selectors)
    {
        selectors = new bytes4[](2); // Initialize array with 2 elements

        selectors[0] = OwnershipFacet.owner.selector;

        selectors[1] = OwnershipFacet.transferOwnership.selector;

        return selectors;
    }

    function getSecurityMonitorFacetSelectors()
        internal
        pure
        returns (bytes4[] memory selectors)
    {
        selectors = new bytes4[](4); // Initialize array with 4 elements

        selectors[0] = SecurityMonitorFacet.checkUpkeep.selector;

        selectors[1] = SecurityMonitorFacet.performUpkeep.selector;

        selectors[2] = SecurityMonitorFacet.setCheckInterval.selector;

        selectors[3] = SecurityMonitorFacet.initialize.selector;

        return selectors;
    }
}
