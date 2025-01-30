// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";

import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {Diamond, DiamondArgs} from "../../src/dollar/Diamond.sol";
import {ERC1155Ubiquity} from "../../src/dollar/core/ERC1155Ubiquity.sol";
import {IDiamondCut} from "../../src/dollar/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "../../src/dollar/interfaces/IDiamondLoupe.sol";
import {IERC173} from "../../src/dollar/interfaces/IERC173.sol";
import {AccessControlFacet} from "../../src/dollar/facets/AccessControlFacet.sol";
import {BondingCurveFacet} from "../../src/dollar/facets/BondingCurveFacet.sol";
import {ChefFacet} from "../../src/dollar/facets/ChefFacet.sol";
import {CollectableDustFacet} from "../../src/dollar/facets/CollectableDustFacet.sol";
import {CreditNftManagerFacet} from "../../src/dollar/facets/CreditNftManagerFacet.sol";
import {CreditNftRedemptionCalculatorFacet} from "../../src/dollar/facets/CreditNftRedemptionCalculatorFacet.sol";
import {CreditRedemptionCalculatorFacet} from "../../src/dollar/facets/CreditRedemptionCalculatorFacet.sol";
import {CreditClockFacet} from "../../src/dollar/facets/CreditClockFacet.sol";
import {CurveDollarIncentiveFacet} from "../../src/dollar/facets/CurveDollarIncentiveFacet.sol";
import {DiamondCutFacet} from "../../src/dollar/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../../src/dollar/facets/DiamondLoupeFacet.sol";
import {DollarMintCalculatorFacet} from "../../src/dollar/facets/DollarMintCalculatorFacet.sol";
import {DollarMintExcessFacet} from "../../src/dollar/facets/DollarMintExcessFacet.sol";
import {DirectGovernanceFarmerFacet} from "../../src/dollar/facets/DirectGovernanceFarmerFacet.sol";
import {ManagerFacet} from "../../src/dollar/facets/ManagerFacet.sol";
import {OwnershipFacet} from "../../src/dollar/facets/OwnershipFacet.sol";
import {StakingFacet} from "../../src/dollar/facets/StakingFacet.sol";
import {StakingFormulasFacet} from "../../src/dollar/facets/StakingFormulasFacet.sol";
import {UbiquityPoolFacet} from "../../src/dollar/facets/UbiquityPoolFacet.sol";
import {MockCurveStableSwapMetaNG} from "../../src/dollar/mocks/MockCurveStableSwapMetaNG.sol";
import {MockERC20} from "../../src/dollar/mocks/MockERC20.sol";
import {DiamondInit} from "../../src/dollar/upgradeInitializers/DiamondInit.sol";
import {DiamondTestHelper} from "../helpers/DiamondTestHelper.sol";
import {UUPSTestHelper} from "../helpers/UUPSTestHelper.sol";
import {CREDIT_NFT_MANAGER_ROLE, CREDIT_TOKEN_BURNER_ROLE, CREDIT_TOKEN_MINTER_ROLE, CURVE_DOLLAR_MANAGER_ROLE, DOLLAR_TOKEN_BURNER_ROLE, DOLLAR_TOKEN_MINTER_ROLE, GOVERNANCE_TOKEN_BURNER_ROLE, GOVERNANCE_TOKEN_MANAGER_ROLE, GOVERNANCE_TOKEN_MINTER_ROLE, STAKING_SHARE_MINTER_ROLE} from "../../src/dollar/libraries/Constants.sol";

/**
 * @notice Deploys diamond contract with all of the facets
 */
abstract contract DiamondTestSetup is DiamondTestHelper, UUPSTestHelper {
    // diamond related contracts
    Diamond diamond;
    DiamondInit diamondInit;

    // diamond facets (which point to the core diamond and should be used across the tests)
    AccessControlFacet accessControlFacet;
    BondingCurveFacet bondingCurveFacet;
    ChefFacet chefFacet;
    CollectableDustFacet collectableDustFacet;
    CreditClockFacet creditClockFacet;
    CreditNftManagerFacet creditNftManagerFacet;
    CreditNftRedemptionCalculatorFacet creditNftRedemptionCalculationFacet;
    CreditRedemptionCalculatorFacet creditRedemptionCalculationFacet;
    CurveDollarIncentiveFacet curveDollarIncentiveFacet;
    DiamondCutFacet diamondCutFacet;
    DiamondLoupeFacet diamondLoupeFacet;
    DollarMintCalculatorFacet dollarMintCalculatorFacet;
    DollarMintExcessFacet dollarMintExcessFacet;
    DirectGovernanceFarmerFacet directGovernanceFarmerFacet;
    ManagerFacet managerFacet;
    OwnershipFacet ownershipFacet;
    StakingFacet stakingFacet;
    StakingFormulasFacet stakingFormulasFacet;
    UbiquityPoolFacet ubiquityPoolFacet;

    // diamond facet implementation instances (should not be used in tests, use only on upgrades)
    AccessControlFacet accessControlFacetImplementation;
    BondingCurveFacet bondingCurveFacetImplementation;
    ChefFacet chefFacetImplementation;
    CollectableDustFacet collectableDustFacetImplementation;
    CreditClockFacet creditClockFacetImplementation;
    CreditNftManagerFacet creditNftManagerFacetImplementation;
    CreditNftRedemptionCalculatorFacet creditNftRedemptionCalculatorFacetImplementation;
    CreditRedemptionCalculatorFacet creditRedemptionCalculatorFacetImplementation;
    CurveDollarIncentiveFacet curveDollarIncentiveFacetImplementation;
    DiamondCutFacet diamondCutFacetImplementation;
    DiamondLoupeFacet diamondLoupeFacetImplementation;
    DollarMintCalculatorFacet dollarMintCalculatorFacetImplementation;
    DollarMintExcessFacet dollarMintExcessFacetImplementation;
    DirectGovernanceFarmerFacet directGovernanceFarmerFacetImplementation;
    ManagerFacet managerFacetImplementation;
    OwnershipFacet ownershipFacetImplementation;
    StakingFacet stakingFacetImplementation;
    StakingFormulasFacet stakingFormulasFacetImplementation;
    UbiquityPoolFacet ubiquityPoolFacetImplementation;

    // facet names with addresses
    string[] facetNames;
    address[] facetAddressList;

    // helper addresses
    address owner;
    address admin;
    address user1;
    address contract1;
    address contract2;

    // selectors for all of the facets
    bytes4[] selectorsOfAccessControlFacet;
    bytes4[] selectorsOfBondingCurveFacet;
    bytes4[] selectorsOfChefFacet;
    bytes4[] selectorsOfCollectableDustFacet;
    bytes4[] selectorsOfCreditClockFacet;
    bytes4[] selectorsOfCreditNftManagerFacet;
    bytes4[] selectorsOfCreditNftRedemptionCalculatorFacet;
    bytes4[] selectorsOfCreditRedemptionCalculatorFacet;
    bytes4[] selectorsOfCurveDollarIncentiveFacet;
    bytes4[] selectorsOfDiamondCutFacet;
    bytes4[] selectorsOfDiamondLoupeFacet;
    bytes4[] selectorsOfDollarMintCalculatorFacet;
    bytes4[] selectorsOfDollarMintExcessFacet;
    bytes4[] selectorsOfDirectGovernanceFarmerFacet;
    bytes4[] selectorsOfManagerFacet;
    bytes4[] selectorsOfOwnershipFacet;
    bytes4[] selectorsOfStakingFacet;
    bytes4[] selectorsOfStakingFormulasFacet;
    bytes4[] selectorsOfUbiquityPoolFacet;

    /// @notice Deploys diamond and connects facets
    function setUp() public virtual {
        // setup helper addresses
        owner = generateAddress("Owner", false, 10 ether);
        admin = generateAddress("Admin", false, 10 ether);
        user1 = generateAddress("User1", false, 10 ether);
        contract1 = generateAddress("Contract1", true, 10 ether);
        contract2 = generateAddress("Contract2", true, 10 ether);

        // set all function selectors
        selectorsOfAccessControlFacet = getSelectorsFromAbi(
            "/out/AccessControlFacet.sol/AccessControlFacet.json"
        );
        selectorsOfBondingCurveFacet = getSelectorsFromAbi(
            "/out/BondingCurveFacet.sol/BondingCurveFacet.json"
        );
        selectorsOfChefFacet = getSelectorsFromAbi(
            "/out/ChefFacet.sol/ChefFacet.json"
        );
        selectorsOfCollectableDustFacet = getSelectorsFromAbi(
            "/out/CollectableDustFacet.sol/CollectableDustFacet.json"
        );
        selectorsOfCreditClockFacet = getSelectorsFromAbi(
            "/out/CreditClockFacet.sol/CreditClockFacet.json"
        );
        selectorsOfCreditNftManagerFacet = getSelectorsFromAbi(
            "/out/CreditNftManagerFacet.sol/CreditNftManagerFacet.json"
        );
        selectorsOfCreditNftRedemptionCalculatorFacet = getSelectorsFromAbi(
            "/out/CreditNftRedemptionCalculatorFacet.sol/CreditNftRedemptionCalculatorFacet.json"
        );
        selectorsOfCreditRedemptionCalculatorFacet = getSelectorsFromAbi(
            "/out/CreditRedemptionCalculatorFacet.sol/CreditRedemptionCalculatorFacet.json"
        );
        selectorsOfCurveDollarIncentiveFacet = getSelectorsFromAbi(
            "/out/CurveDollarIncentiveFacet.sol/CurveDollarIncentiveFacet.json"
        );
        selectorsOfDiamondCutFacet = getSelectorsFromAbi(
            "/out/DiamondCutFacet.sol/DiamondCutFacet.json"
        );
        selectorsOfDiamondLoupeFacet = getSelectorsFromAbi(
            "/out/DiamondLoupeFacet.sol/DiamondLoupeFacet.json"
        );
        selectorsOfDollarMintCalculatorFacet = getSelectorsFromAbi(
            "/out/DollarMintCalculatorFacet.sol/DollarMintCalculatorFacet.json"
        );
        selectorsOfDollarMintExcessFacet = getSelectorsFromAbi(
            "/out/DollarMintExcessFacet.sol/DollarMintExcessFacet.json"
        );
        selectorsOfDirectGovernanceFarmerFacet = getSelectorsFromAbi(
            "/out/DirectGovernanceFarmerFacet.sol/DirectGovernanceFarmerFacet.json"
        );
        selectorsOfManagerFacet = getSelectorsFromAbi(
            "/out/ManagerFacet.sol/ManagerFacet.json"
        );
        selectorsOfOwnershipFacet = getSelectorsFromAbi(
            "/out/OwnershipFacet.sol/OwnershipFacet.json"
        );
        selectorsOfStakingFacet = getSelectorsFromAbi(
            "/out/StakingFacet.sol/StakingFacet.json"
        );
        selectorsOfStakingFormulasFacet = getSelectorsFromAbi(
            "/out/StakingFormulasFacet.sol/StakingFormulasFacet.json"
        );
        selectorsOfUbiquityPoolFacet = getSelectorsFromAbi(
            "/out/UbiquityPoolFacet.sol/UbiquityPoolFacet.json"
        );

        // deploy facet implementation instances
        accessControlFacetImplementation = new AccessControlFacet();
        bondingCurveFacetImplementation = new BondingCurveFacet();
        chefFacetImplementation = new ChefFacet();
        collectableDustFacetImplementation = new CollectableDustFacet();
        creditClockFacetImplementation = new CreditClockFacet();
        creditNftManagerFacetImplementation = new CreditNftManagerFacet();
        creditNftRedemptionCalculatorFacetImplementation = new CreditNftRedemptionCalculatorFacet();
        creditRedemptionCalculatorFacetImplementation = new CreditRedemptionCalculatorFacet();
        curveDollarIncentiveFacetImplementation = new CurveDollarIncentiveFacet();
        diamondCutFacetImplementation = new DiamondCutFacet();
        diamondLoupeFacetImplementation = new DiamondLoupeFacet();
        dollarMintCalculatorFacetImplementation = new DollarMintCalculatorFacet();
        dollarMintExcessFacetImplementation = new DollarMintExcessFacet();
        directGovernanceFarmerFacetImplementation = new DirectGovernanceFarmerFacet();
        managerFacetImplementation = new ManagerFacet();
        ownershipFacetImplementation = new OwnershipFacet();
        stakingFacetImplementation = new StakingFacet();
        stakingFormulasFacetImplementation = new StakingFormulasFacet();
        ubiquityPoolFacetImplementation = new UbiquityPoolFacet();

        // prepare diamond init args
        diamondInit = new DiamondInit();
        facetNames = [
            "AccessControlFacet",
            "BondingCurveFacet",
            "ChefFacet",
            "CollectableDustFacet",
            "CreditClockFacet",
            "CreditNftManagerFacet",
            "CreditNftRedemptionCalculatorFacet",
            "CreditRedemptionCalculatorFacet",
            "CurveDollarIncentiveFacet",
            "DiamondCutFacet",
            "DiamondLoupeFacet",
            "DollarMintCalculatorFacet",
            "DollarMintExcessFacet",
            "DirectGovernanceFarmerFacet",
            "ManagerFacet",
            "OwnershipFacet",
            "StakingFacet",
            "StakingFormulasFacet",
            "UbiquityPoolFacet"
        ];
        DiamondInit.Args memory initArgs = DiamondInit.Args({
            admin: admin,
            tos: new address[](0),
            amounts: new uint256[](0),
            stakingShareIDs: new uint256[](0),
            governancePerBlock: 10e18,
            creditNftLengthBlocks: 100
        });
        // diamond arguments
        DiamondArgs memory _args = DiamondArgs({
            owner: owner,
            init: address(diamondInit),
            initCalldata: abi.encodeWithSelector(
                DiamondInit.init.selector,
                initArgs
            )
        });

        FacetCut[] memory cuts = new FacetCut[](19);

        cuts[0] = (
            FacetCut({
                facetAddress: address(accessControlFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfAccessControlFacet
            })
        );
        cuts[1] = (
            FacetCut({
                facetAddress: address(bondingCurveFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfBondingCurveFacet
            })
        );
        cuts[2] = (
            FacetCut({
                facetAddress: address(chefFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfChefFacet
            })
        );
        cuts[3] = (
            FacetCut({
                facetAddress: address(collectableDustFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfCollectableDustFacet
            })
        );
        cuts[4] = (
            FacetCut({
                facetAddress: address(creditClockFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfCreditClockFacet
            })
        );
        cuts[5] = (
            FacetCut({
                facetAddress: address(creditNftManagerFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfCreditNftManagerFacet
            })
        );
        cuts[6] = (
            FacetCut({
                facetAddress: address(
                    creditNftRedemptionCalculatorFacetImplementation
                ),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfCreditNftRedemptionCalculatorFacet
            })
        );
        cuts[7] = (
            FacetCut({
                facetAddress: address(
                    creditRedemptionCalculatorFacetImplementation
                ),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfCreditRedemptionCalculatorFacet
            })
        );
        cuts[8] = (
            FacetCut({
                facetAddress: address(curveDollarIncentiveFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfCurveDollarIncentiveFacet
            })
        );
        cuts[9] = (
            FacetCut({
                facetAddress: address(diamondCutFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfDiamondCutFacet
            })
        );
        cuts[10] = (
            FacetCut({
                facetAddress: address(diamondLoupeFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfDiamondLoupeFacet
            })
        );
        cuts[11] = (
            FacetCut({
                facetAddress: address(dollarMintCalculatorFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfDollarMintCalculatorFacet
            })
        );
        cuts[12] = (
            FacetCut({
                facetAddress: address(dollarMintExcessFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfDollarMintExcessFacet
            })
        );
        cuts[13] = (
            FacetCut({
                facetAddress: address(
                    directGovernanceFarmerFacetImplementation
                ),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfDirectGovernanceFarmerFacet
            })
        );
        cuts[14] = (
            FacetCut({
                facetAddress: address(managerFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfManagerFacet
            })
        );
        cuts[15] = (
            FacetCut({
                facetAddress: address(ownershipFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfOwnershipFacet
            })
        );
        cuts[16] = (
            FacetCut({
                facetAddress: address(stakingFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfStakingFacet
            })
        );
        cuts[17] = (
            FacetCut({
                facetAddress: address(stakingFormulasFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfStakingFormulasFacet
            })
        );
        cuts[18] = (
            FacetCut({
                facetAddress: address(ubiquityPoolFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfUbiquityPoolFacet
            })
        );

        // deploy diamond
        vm.prank(owner);
        diamond = new Diamond(_args, cuts);

        // initialize diamond facets which point to the core diamond contract
        accessControlFacet = AccessControlFacet(address(diamond));
        bondingCurveFacet = BondingCurveFacet(address(diamond));
        chefFacet = ChefFacet(address(diamond));
        collectableDustFacet = CollectableDustFacet(address(diamond));
        creditClockFacet = CreditClockFacet(address(diamond));
        creditNftManagerFacet = CreditNftManagerFacet(address(diamond));
        creditNftRedemptionCalculationFacet = CreditNftRedemptionCalculatorFacet(
            address(diamond)
        );
        creditRedemptionCalculationFacet = CreditRedemptionCalculatorFacet(
            address(diamond)
        );
        curveDollarIncentiveFacet = CurveDollarIncentiveFacet(address(diamond));
        diamondCutFacet = DiamondCutFacet(address(diamond));
        diamondLoupeFacet = DiamondLoupeFacet(address(diamond));
        dollarMintCalculatorFacet = DollarMintCalculatorFacet(address(diamond));
        dollarMintExcessFacet = DollarMintExcessFacet(address(diamond));
        directGovernanceFarmerFacet = DirectGovernanceFarmerFacet(
            address(diamond)
        );
        managerFacet = ManagerFacet(address(diamond));
        ownershipFacet = OwnershipFacet(address(diamond));
        stakingFacet = StakingFacet(address(diamond));
        stakingFormulasFacet = StakingFormulasFacet(address(diamond));
        ubiquityPoolFacet = UbiquityPoolFacet(address(diamond));

        // get all addresses
        facetAddressList = diamondLoupeFacet.facetAddresses();

        vm.startPrank(admin);

        // grant diamond dollar minting and burning rights
        accessControlFacet.grantRole(
            CURVE_DOLLAR_MANAGER_ROLE,
            address(diamond)
        );
        // grant diamond dollar minting and burning rights
        accessControlFacet.grantRole(
            DOLLAR_TOKEN_MINTER_ROLE,
            address(diamond)
        );
        accessControlFacet.grantRole(
            DOLLAR_TOKEN_BURNER_ROLE,
            address(diamond)
        );
        // grand diamond Credit token minting and burning rights
        accessControlFacet.grantRole(
            CREDIT_TOKEN_MINTER_ROLE,
            address(diamond)
        );
        accessControlFacet.grantRole(
            CREDIT_TOKEN_BURNER_ROLE,
            address(diamond)
        );
        // grant diamond Governance token admin, minter and burner rights
        accessControlFacet.grantRole(
            GOVERNANCE_TOKEN_MANAGER_ROLE,
            address(diamond)
        );
        accessControlFacet.grantRole(
            GOVERNANCE_TOKEN_MINTER_ROLE,
            address(diamond)
        );
        accessControlFacet.grantRole(
            GOVERNANCE_TOKEN_BURNER_ROLE,
            address(diamond)
        );
        // grant diamond token minter rights
        accessControlFacet.grantRole(
            STAKING_SHARE_MINTER_ROLE,
            address(diamond)
        );

        // init UUPS core contracts
        __setupUUPS(address(diamond));

        // deploy Curve's Dollar-3CRVLP metapool
        MockERC20 curveTriPoolLpToken = new MockERC20("3CRV", "3CRV", 18);
        MockCurveStableSwapMetaNG curveDollarMetaPool = new MockCurveStableSwapMetaNG(
                address(dollarToken),
                address(curveTriPoolLpToken)
            );
        managerFacet.setStableSwapMetaPoolAddress(address(curveDollarMetaPool));

        vm.stopPrank();
    }
}
