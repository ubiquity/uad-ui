// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./DiamondTestSetup.sol";
import {IMockFacet, MockFacetInitializer, MockFacetWithPureFunctions, MockFacetWithStorageWriteFunctions, MockFacetWithExtendedStorageWriteFunctions} from "../../src/dollar/mocks/MockFacet.sol";

contract TestDiamond is DiamondTestSetup {
    address pureFacet = address(new MockFacetWithPureFunctions());
    address writeFacet = address(new MockFacetWithStorageWriteFunctions());
    address writeFacetWithInitializer =
        address(new MockFacetWithExtendedStorageWriteFunctions());
    address facetInitializer = address(new MockFacetInitializer());

    function test_ShouldSupportInspectingFacetsAndFunctions() public {
        bool isSupported = IERC165(address(diamond)).supportsInterface(
            type(IDiamondLoupe).interfaceId
        );
        assertEq(isSupported, true);
    }

    function testHasMultipleFacets() public {
        assertEq(facetAddressList.length, 19);
    }

    function testFacetsHaveCorrectSelectors() public {
        for (uint256 i = 0; i < facetAddressList.length; i++) {
            bytes4[] memory fromLoupeFacet = diamondLoupeFacet
                .facetFunctionSelectors(facetAddressList[i]);
            if (compareStrings(facetNames[i], "DiamondCutFacet")) {
                assertTrue(
                    sameMembers(fromLoupeFacet, selectorsOfDiamondCutFacet)
                );
            } else if (compareStrings(facetNames[i], "DiamondLoupeFacet")) {
                assertTrue(
                    sameMembers(fromLoupeFacet, selectorsOfDiamondLoupeFacet)
                );
            } else if (compareStrings(facetNames[i], "OwnershipFacet")) {
                assertTrue(
                    sameMembers(fromLoupeFacet, selectorsOfOwnershipFacet)
                );
            } else if (compareStrings(facetNames[i], "ManagerFacet")) {
                assertTrue(
                    sameMembers(fromLoupeFacet, selectorsOfManagerFacet)
                );
            }
        }
    }

    function testLoupeFacetAddressesEqualsTheListOfAvailableFacets() public {
        address[] memory facetAddresses = diamondLoupeFacet.facetAddresses();
        Facet[] memory facets = diamondLoupeFacet.facets();

        for (uint256 i = 0; i < facetAddresses.length; i++) {
            assertEq(facets[i].facetAddress, facetAddresses[i]);
        }
    }

    function testCutFacetShouldRevertWhenNotOwner() public {
        FacetCut[] memory facetCut = new FacetCut[](1);
        facetCut[0] = FacetCut({
            facetAddress: address(pureFacet),
            action: FacetCutAction.Add,
            functionSelectors: selectorsOfCollectableDustFacet
        });

        vm.expectRevert("LibDiamond: Must be contract owner");

        vm.prank(user1);
        diamondCutFacet.diamondCut(facetCut, address(0x0), "");
    }

    function testCutFacetShouldRevertWhenFunctionAlreadyExists() public {
        FacetCut[] memory facetCut = new FacetCut[](1);
        facetCut[0] = FacetCut({
            facetAddress: address(collectableDustFacetImplementation),
            action: FacetCutAction.Add,
            functionSelectors: selectorsOfCollectableDustFacet
        });

        vm.expectRevert(
            "LibDiamondCut: Can't add function that already exists"
        );

        vm.prank(owner);
        diamondCutFacet.diamondCut(facetCut, address(0x0), "");
    }

    function testCutFacetShouldRevertWhenNoSelectorsProvidedForFacetForCut()
        public
    {
        FacetCut[] memory facetCut = new FacetCut[](1);
        facetCut[0] = FacetCut({
            facetAddress: address(pureFacet),
            action: FacetCutAction.Add,
            functionSelectors: new bytes4[](0)
        });

        vm.expectRevert("LibDiamondCut: No selectors in facet to cut");

        vm.prank(owner);
        diamondCutFacet.diamondCut(facetCut, address(0x0), "");
    }

    function testCutFacetShouldRevertWhenAddToZeroAddress() public {
        FacetCut[] memory facetCut = new FacetCut[](1);
        facetCut[0] = FacetCut({
            facetAddress: address(0),
            action: FacetCutAction.Add,
            functionSelectors: selectorsOfCollectableDustFacet
        });

        vm.expectRevert("LibDiamondCut: Add facet can't be address(0)");

        vm.prank(owner);
        diamondCutFacet.diamondCut(facetCut, address(0x0), "");
    }

    function testCutFacetShouldRevertWhenFacetInitializerReverts() public {
        FacetCut[] memory facetCut = new FacetCut[](1);
        facetCut[0] = FacetCut({
            facetAddress: address(pureFacet),
            action: FacetCutAction.Replace,
            functionSelectors: selectorsOfCollectableDustFacet
        });

        vm.expectRevert();

        vm.prank(owner);
        diamondCutFacet.diamondCut(
            facetCut,
            facetInitializer,
            abi.encodeWithSelector(
                MockFacetInitializer.initializeRevert.selector
            )
        );
    }

    function testCutFacetShouldRevertWithMessageWhenFacetInitializerWithMessageReverts()
        public
    {
        FacetCut[] memory facetCut = new FacetCut[](1);
        facetCut[0] = FacetCut({
            facetAddress: address(pureFacet),
            action: FacetCutAction.Replace,
            functionSelectors: selectorsOfCollectableDustFacet
        });

        vm.expectRevert("MockFacetError");

        vm.prank(owner);
        diamondCutFacet.diamondCut(
            facetCut,
            facetInitializer,
            abi.encodeWithSelector(
                MockFacetInitializer.initializeRevertWithMessage.selector
            )
        );
    }

    function testCutFacetAddSimplePureFacet() public {
        FacetCut[] memory facetCut = new FacetCut[](1);
        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = MockFacetWithPureFunctions.functionA.selector;
        selectors[1] = MockFacetWithPureFunctions.functionB.selector;

        facetCut[0] = FacetCut({
            facetAddress: address(pureFacet),
            action: FacetCutAction.Add,
            functionSelectors: selectors
        });

        vm.prank(owner);
        diamondCutFacet.diamondCut(facetCut, address(0x0), "");

        assertEq(IMockFacet(address(diamondCutFacet)).functionA(), 1);
        assertEq(IMockFacet(address(diamondCutFacet)).functionB(), 2);
    }

    function testCutFacetAddSimpleWriteFacet() public {
        FacetCut[] memory facetCut = new FacetCut[](1);
        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = MockFacetWithStorageWriteFunctions.functionA.selector;
        selectors[1] = MockFacetWithStorageWriteFunctions.functionB.selector;

        facetCut[0] = FacetCut({
            facetAddress: address(writeFacet),
            action: FacetCutAction.Add,
            functionSelectors: selectors
        });

        vm.prank(owner);
        diamondCutFacet.diamondCut(facetCut, address(0x0), "");

        assertEq(IMockFacet(address(diamondCutFacet)).functionA(), 0);
        assertEq(IMockFacet(address(diamondCutFacet)).functionB(), 1);
    }

    function testCutFacetAddWriteFacetWithInitializer() public {
        FacetCut[] memory facetCut = new FacetCut[](1);
        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = MockFacetWithExtendedStorageWriteFunctions
            .functionA
            .selector;
        selectors[1] = MockFacetWithExtendedStorageWriteFunctions
            .functionB
            .selector;

        facetCut[0] = FacetCut({
            facetAddress: address(writeFacetWithInitializer),
            action: FacetCutAction.Add,
            functionSelectors: selectors
        });

        vm.prank(owner);
        diamondCutFacet.diamondCut(
            facetCut,
            facetInitializer,
            abi.encodeWithSelector(MockFacetInitializer.initialize.selector)
        );

        // initializer should set 2 and 22 values
        assertEq(IMockFacet(address(diamondCutFacet)).functionA(), 2);
        assertEq(IMockFacet(address(diamondCutFacet)).functionB(), 22);
    }

    function testCutFacetReplaceFacet() public {
        FacetCut[] memory facetCut = new FacetCut[](1);
        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = MockFacetWithPureFunctions.functionA.selector;
        selectors[1] = MockFacetWithPureFunctions.functionB.selector;

        facetCut[0] = FacetCut({
            facetAddress: address(pureFacet),
            action: FacetCutAction.Add,
            functionSelectors: selectors
        });

        vm.prank(owner);
        diamondCutFacet.diamondCut(facetCut, address(0x0), "");

        assertEq(IMockFacet(address(diamondCutFacet)).functionA(), 1);
        assertEq(IMockFacet(address(diamondCutFacet)).functionB(), 2);

        facetCut[0] = FacetCut({
            facetAddress: address(writeFacet),
            action: FacetCutAction.Replace,
            functionSelectors: selectors
        });

        vm.prank(owner);
        diamondCutFacet.diamondCut(facetCut, address(0x0), "");

        assertEq(IMockFacet(address(diamondCutFacet)).functionA(), 0);
        assertEq(IMockFacet(address(diamondCutFacet)).functionB(), 1);
    }

    function testCutFacetRemoveFacetFunctions() public {
        FacetCut[] memory facetCut = new FacetCut[](1);
        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = MockFacetWithStorageWriteFunctions.functionA.selector;
        selectors[1] = MockFacetWithStorageWriteFunctions.functionB.selector;

        facetCut[0] = FacetCut({
            facetAddress: address(writeFacet),
            action: FacetCutAction.Add,
            functionSelectors: selectors
        });

        vm.prank(owner);
        diamondCutFacet.diamondCut(facetCut, address(0x0), "");

        assertEq(IMockFacet(address(diamondCutFacet)).functionA(), 0);
        assertEq(IMockFacet(address(diamondCutFacet)).functionB(), 1);

        facetCut[0] = FacetCut({
            facetAddress: address(0),
            action: FacetCutAction.Remove,
            functionSelectors: selectors
        });

        vm.prank(owner);
        diamondCutFacet.diamondCut(facetCut, address(0x0), "");

        vm.expectRevert("Diamond: Function does not exist");
        IMockFacet(address(diamondCutFacet)).functionA();
        vm.expectRevert("Diamond: Function does not exist");
        IMockFacet(address(diamondCutFacet)).functionB();
    }

    function testCutFacetShouldNotRemoveDiamondCutFunction() public {
        FacetCut[] memory facetCut = new FacetCut[](1);
        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = diamondCutFacet.diamondCut.selector;

        facetCut[0] = FacetCut({
            facetAddress: address(0),
            action: FacetCutAction.Remove,
            functionSelectors: selectors
        });

        // try to remove diamondCut function
        vm.prank(owner);
        vm.expectRevert("LibDiamondCut: Can't remove diamondCut function");
        diamondCutFacet.diamondCut(facetCut, address(0x0), "");
    }

    function testSelectors_ShouldBeAssociatedWithCorrectFacet() public {
        for (uint256 i; i < facetAddressList.length; i++) {
            if (compareStrings(facetNames[i], "DiamondCutFacet")) {
                for (uint256 j; j < selectorsOfDiamondCutFacet.length; j++) {
                    assertEq(
                        facetAddressList[i],
                        diamondLoupeFacet.facetAddress(
                            selectorsOfDiamondCutFacet[j]
                        )
                    );
                }
            } else if (compareStrings(facetNames[i], "DiamondLoupeFacet")) {
                for (uint256 j; j < selectorsOfDiamondLoupeFacet.length; j++) {
                    assertEq(
                        facetAddressList[i],
                        diamondLoupeFacet.facetAddress(
                            selectorsOfDiamondLoupeFacet[j]
                        )
                    );
                }
            } else if (compareStrings(facetNames[i], "OwnershipFacet")) {
                for (uint256 j; j < selectorsOfOwnershipFacet.length; j++) {
                    assertEq(
                        facetAddressList[i],
                        diamondLoupeFacet.facetAddress(
                            selectorsOfOwnershipFacet[j]
                        )
                    );
                }
            } else if (compareStrings(facetNames[i], "ManagerFacet")) {
                for (uint256 j; j < selectorsOfManagerFacet.length; j++) {
                    assertEq(
                        facetAddressList[i],
                        diamondLoupeFacet.facetAddress(
                            selectorsOfManagerFacet[j]
                        )
                    );
                }
            }
        }
    }

    function testFallback_ShouldRevert_IfSelectorIsTooShort() public {
        // pass 3 bytes selector while normally it should be 4 bytes length
        vm.expectRevert(bytes("Diamond: Selector is too short"));
        (bool revertsAsExpected, ) = address(diamond).call(bytes("000"));
        // NOTICE: for low level calls (like `address.call()`) the returned result
        // is NOT the success of the low level call but the success of the `vm.expectRevert()`
        // expression, more info: https://book.getfoundry.sh/cheatcodes/expect-revert
        assertTrue(revertsAsExpected);
    }
}
