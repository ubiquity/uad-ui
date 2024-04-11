// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/interfaces/AggregatorV3Interface.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Script} from "forge-std/Script.sol";
import {UbiquityAlgorithmicDollarManager} from "../../src/deprecated/UbiquityAlgorithmicDollarManager.sol";
import {UbiquityGovernance} from "../../src/deprecated/UbiquityGovernance.sol";
import {Diamond, DiamondArgs} from "../../src/dollar/Diamond.sol";
import {UbiquityDollarToken} from "../../src/dollar/core/UbiquityDollarToken.sol";
import {AccessControlFacet} from "../../src/dollar/facets/AccessControlFacet.sol";
import {DiamondCutFacet} from "../../src/dollar/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../../src/dollar/facets/DiamondLoupeFacet.sol";
import {ManagerFacet} from "../../src/dollar/facets/ManagerFacet.sol";
import {OwnershipFacet} from "../../src/dollar/facets/OwnershipFacet.sol";
import {UbiquityPoolFacet} from "../../src/dollar/facets/UbiquityPoolFacet.sol";
import {ICurveStableSwapMetaNG} from "../../src/dollar/interfaces/ICurveStableSwapMetaNG.sol";
import {ICurveTwocryptoOptimized} from "../../src/dollar/interfaces/ICurveTwocryptoOptimized.sol";
import {IDiamondCut} from "../../src/dollar/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "../../src/dollar/interfaces/IDiamondLoupe.sol";
import {IERC173} from "../../src/dollar/interfaces/IERC173.sol";
import {DEFAULT_ADMIN_ROLE, DOLLAR_TOKEN_MINTER_ROLE, DOLLAR_TOKEN_BURNER_ROLE, GOVERNANCE_TOKEN_MINTER_ROLE, GOVERNANCE_TOKEN_BURNER_ROLE, PAUSER_ROLE} from "../../src/dollar/libraries/Constants.sol";
import {LibAccessControl} from "../../src/dollar/libraries/LibAccessControl.sol";
import {AppStorage, LibAppStorage, Modifiers} from "../../src/dollar/libraries/LibAppStorage.sol";
import {LibDiamond} from "../../src/dollar/libraries/LibDiamond.sol";
import {MockChainLinkFeed} from "../../src/dollar/mocks/MockChainLinkFeed.sol";
import {MockCurveStableSwapMetaNG} from "../../src/dollar/mocks/MockCurveStableSwapMetaNG.sol";
import {MockCurveTwocryptoOptimized} from "../../src/dollar/mocks/MockCurveTwocryptoOptimized.sol";
import {MockERC20} from "../../src/dollar/mocks/MockERC20.sol";
import {DiamondTestHelper} from "../../test/helpers/DiamondTestHelper.sol";

/**
 * @notice It is expected that this contract is customized if you want to deploy your diamond
 * with data from a deployment script. Use the init function to initialize state variables
 * of your diamond. Add parameters to the init function if you need to.
 *
 * @notice How it works:
 * 1. New `Diamond` contract is created
 * 2. Inside the diamond's constructor there is a `delegatecall()` to `DiamondInit` with the provided args
 * 3. `DiamondInit` updates diamond storage
 */
contract DiamondInit is Modifiers {
    /// @notice Struct used for diamond initialization
    struct Args {
        address admin;
    }

    /**
     * @notice Initializes a diamond with state variables
     * @dev You can add parameters to this function in order to pass in data to set your own state variables
     * @param _args Init args
     */
    function init(Args memory _args) external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        LibAccessControl.grantRole(DEFAULT_ADMIN_ROLE, _args.admin);
        LibAccessControl.grantRole(DOLLAR_TOKEN_MINTER_ROLE, _args.admin);
        LibAccessControl.grantRole(DOLLAR_TOKEN_BURNER_ROLE, _args.admin);
        LibAccessControl.grantRole(PAUSER_ROLE, _args.admin);

        AppStorage storage appStore = LibAppStorage.appStorage();
        appStore.paused = false;
        appStore.treasuryAddress = _args.admin;

        // reentrancy guard
        _initReentrancyGuard();
    }
}

/**
 * @notice Migration contract
 * @dev Initial production migration includes the following contracts:
 * - Dollar token
 * - Governance token (already deployed https://etherscan.io/address/0x4e38D89362f7e5db0096CE44ebD021c3962aA9a0)
 * - UbiquityPool (which is a facet of the Diamond contract)
 *
 * So we're deploying only contracts and facets necessary for features
 * connected with the contracts above. Hence we omit the following facets
 * from deployment:
 * - BondingCurveFacet (used for UbiquiStick NFT, "on hold" now)
 * - ChefFacet (staking is not a part of the initial deployment)
 * - CollectableDustFacet (could be useful but not a must now)
 * - CreditClockFacet (used for CreditNft which is not a part of the initial deployment)
 * - CreditNftManagerFacet (used for CreditNft which is not a part of the initial deployment)
 * - CreditNftRedemptionCalculatorFacet (used for CreditNft which is not a part of the initial deployment)
 * - CreditRedemptionCalculatorFacet (used for Credit token which is not a part of the initial deployment)
 * - CurveDollarIncentiveFacet (deprecated)
 * - DollarMintCalculatorFacet (used for Dollar/Credit mint/burn mechanism which is not a part of the initial deployment)
 * - DollarMintExcessFacet (used for Dollar/Credit mint/burn mechanism which is not a part of the initial deployment)
 * - StakingFacet (staking is not a part of the initial deployment)
 * - StakingFormulasFacet (staking is not a part of the initial deployment)
 */
contract Deploy001_Diamond_Dollar_Governance is Script, DiamondTestHelper {
    // env variables
    uint256 adminPrivateKey;
    uint256 ownerPrivateKey;
    uint256 initialDollarMintAmountWei;

    // owner and admin addresses derived from private keys store in `.env` file
    address adminAddress;
    address ownerAddress;

    // threshold in seconds when price feed response should be considered stale
    uint256 CHAINLINK_PRICE_FEED_THRESHOLD;

    // Dollar related contracts
    UbiquityDollarToken public dollarToken;
    ERC1967Proxy public proxyDollarToken;

    // diamond related contracts
    Diamond diamond;
    DiamondInit diamondInit;

    // diamond facet implementation instances (should not be used directly)
    AccessControlFacet accessControlFacetImplementation;
    DiamondCutFacet diamondCutFacetImplementation;
    DiamondLoupeFacet diamondLoupeFacetImplementation;
    ManagerFacet managerFacetImplementation;
    OwnershipFacet ownershipFacetImplementation;
    UbiquityPoolFacet ubiquityPoolFacetImplementation;

    // oracle related contracts
    AggregatorV3Interface chainLinkPriceFeedEth; // chainlink ETH/USD price feed
    AggregatorV3Interface chainLinkPriceFeedLusd; // chainlink LUSD/USD price feed
    IERC20 curveTriPoolLpToken; // Curve's 3CRV-LP token
    ICurveStableSwapMetaNG curveDollarMetaPool; // Curve's Dollar-3CRVLP metapool
    ICurveTwocryptoOptimized curveGovernanceEthPool; // Curve's Governance-WETH crypto pool

    // collateral ERC20 token used in UbiquityPoolFacet
    IERC20 collateralToken;

    // Governance token related contracts
    UbiquityAlgorithmicDollarManager ubiquityAlgorithmicDollarManager;
    UbiquityGovernance ubiquityGovernance;

    // selectors for all of the facets
    bytes4[] selectorsOfAccessControlFacet;
    bytes4[] selectorsOfDiamondCutFacet;
    bytes4[] selectorsOfDiamondLoupeFacet;
    bytes4[] selectorsOfManagerFacet;
    bytes4[] selectorsOfOwnershipFacet;
    bytes4[] selectorsOfUbiquityPoolFacet;

    function run() public virtual {
        // read env variables
        adminPrivateKey = vm.envUint("ADMIN_PRIVATE_KEY");
        ownerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");
        initialDollarMintAmountWei = vm.envUint(
            "INITIAL_DOLLAR_MINT_AMOUNT_WEI"
        );

        adminAddress = vm.addr(adminPrivateKey);
        ownerAddress = vm.addr(ownerPrivateKey);

        //==================
        // Before scripts
        //==================

        beforeRun();

        //===================
        // Deploy Diamond
        //===================

        // start sending owner transactions
        vm.startBroadcast(ownerPrivateKey);

        // set all function selectors
        selectorsOfAccessControlFacet = getSelectorsFromAbi(
            "/out/AccessControlFacet.sol/AccessControlFacet.json"
        );
        selectorsOfDiamondCutFacet = getSelectorsFromAbi(
            "/out/DiamondCutFacet.sol/DiamondCutFacet.json"
        );
        selectorsOfDiamondLoupeFacet = getSelectorsFromAbi(
            "/out/DiamondLoupeFacet.sol/DiamondLoupeFacet.json"
        );
        selectorsOfManagerFacet = getSelectorsFromAbi(
            "/out/ManagerFacet.sol/ManagerFacet.json"
        );
        selectorsOfOwnershipFacet = getSelectorsFromAbi(
            "/out/OwnershipFacet.sol/OwnershipFacet.json"
        );
        selectorsOfUbiquityPoolFacet = getSelectorsFromAbi(
            "/out/UbiquityPoolFacet.sol/UbiquityPoolFacet.json"
        );

        // deploy facet implementation instances
        accessControlFacetImplementation = new AccessControlFacet();
        diamondCutFacetImplementation = new DiamondCutFacet();
        diamondLoupeFacetImplementation = new DiamondLoupeFacet();
        managerFacetImplementation = new ManagerFacet();
        ownershipFacetImplementation = new OwnershipFacet();
        ubiquityPoolFacetImplementation = new UbiquityPoolFacet();

        // prepare DiamondInit args
        diamondInit = new DiamondInit();
        DiamondInit.Args memory diamondInitArgs = DiamondInit.Args({
            admin: adminAddress
        });
        // prepare Diamond arguments
        DiamondArgs memory diamondArgs = DiamondArgs({
            owner: ownerAddress,
            init: address(diamondInit),
            initCalldata: abi.encodeWithSelector(
                DiamondInit.init.selector,
                diamondInitArgs
            )
        });

        // prepare facet cuts
        FacetCut[] memory cuts = new FacetCut[](6);
        cuts[0] = (
            FacetCut({
                facetAddress: address(accessControlFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfAccessControlFacet
            })
        );
        cuts[1] = (
            FacetCut({
                facetAddress: address(diamondCutFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfDiamondCutFacet
            })
        );
        cuts[2] = (
            FacetCut({
                facetAddress: address(diamondLoupeFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfDiamondLoupeFacet
            })
        );
        cuts[3] = (
            FacetCut({
                facetAddress: address(managerFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfManagerFacet
            })
        );
        cuts[4] = (
            FacetCut({
                facetAddress: address(ownershipFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfOwnershipFacet
            })
        );
        cuts[5] = (
            FacetCut({
                facetAddress: address(ubiquityPoolFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfUbiquityPoolFacet
            })
        );

        // deploy diamond
        diamond = new Diamond(diamondArgs, cuts);

        // stop sending owner transactions
        vm.stopBroadcast();

        //=======================
        // Diamond permissions
        //=======================

        // start sending admin transactions
        vm.startBroadcast(adminPrivateKey);

        AccessControlFacet accessControlFacet = AccessControlFacet(
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

        // stop sending admin transactions
        vm.stopBroadcast();

        //=========================
        // UbiquiPoolFacet setup
        //=========================

        // start sending admin transactions
        vm.startBroadcast(adminPrivateKey);

        UbiquityPoolFacet ubiquityPoolFacet = UbiquityPoolFacet(
            address(diamond)
        );

        // add collateral token (users can mint/redeem Dollars in exchange for collateral)
        uint256 poolCeiling = 10_000e18; // max 10_000 of collateral tokens is allowed

        ubiquityPoolFacet.addCollateralToken(
            address(collateralToken), // collateral token address
            address(chainLinkPriceFeedLusd), // chainlink LUSD/USD price feed address
            poolCeiling // pool ceiling amount
        );
        // enable collateral at index 0
        ubiquityPoolFacet.toggleCollateral(0);
        // set mint and redeem fees
        ubiquityPoolFacet.setFees(
            0, // collateral index
            0, // 0% mint fee
            0 // 0% redeem fee
        );
        // set redemption delay to 2 blocks
        ubiquityPoolFacet.setRedemptionDelayBlocks(2);
        // set mint price threshold to $1.01 and redeem price to $0.99
        ubiquityPoolFacet.setPriceThresholds(1010000, 990000);
        // set collateral ratio to 95%
        ubiquityPoolFacet.setCollateralRatio(950_000);

        // stop sending admin transactions
        vm.stopBroadcast();

        //==================
        // Dollar deploy
        //==================

        // start sending owner transactions
        vm.startBroadcast(ownerPrivateKey);

        // deploy proxy
        bytes memory initDollarPayload = abi.encodeWithSignature(
            "initialize(address)",
            address(diamond)
        );
        proxyDollarToken = new ERC1967Proxy(
            address(new UbiquityDollarToken()),
            initDollarPayload
        );

        // get Dollar contract which should be used in the frontend
        dollarToken = UbiquityDollarToken(address(proxyDollarToken));

        // stop sending owner transactions
        vm.stopBroadcast();

        //================
        // Dollar setup
        //================

        // start sending admin transactions
        vm.startBroadcast(adminPrivateKey);

        // set Dollar token address in the Diamond
        ManagerFacet managerFacet = ManagerFacet(address(diamond));
        managerFacet.setDollarTokenAddress(address(dollarToken));

        // mint initial Dollar amount to owner for Curve's Dollar-3CRV metapool
        dollarToken.mint(ownerAddress, initialDollarMintAmountWei);

        // stop sending admin transactions
        vm.stopBroadcast();

        //=================
        // After scripts
        //=================

        afterRun();
    }

    /**
     * @notice Runs before the main `run()` method
     *
     * @dev Initializes collateral token
     * @dev Collateral token is different for mainnet and development:
     * - mainnet: uses LUSD address from `COLLATERAL_TOKEN_ADDRESS` env variables
     * - development: deploys mocked ERC20 token from scratch
     */
    function beforeRun() public virtual {
        //=================================
        // Collateral ERC20 token deploy
        //=================================

        // start sending owner transactions
        vm.startBroadcast(ownerPrivateKey);

        // deploy ERC20 mock token for ease of debugging
        collateralToken = new MockERC20(
            "Collateral test token",
            "CLT_TEST",
            18
        );

        // stop sending owner transactions
        vm.stopBroadcast();
    }

    /**
     * @notice Runs after the main `run()` method
     *
     * @dev Initializes:
     * - oracle related contracts
     * - Governance token related contracts
     *
     * @dev Ubiquity protocol supports 4 oracles:
     * 1. Curve's Dollar-3CRVLP metapool to fetch Dollar prices
     * 2. Chainlink's price feed (used in UbiquityPool) to fetch collateral token prices in USD
     * 3. Chainlink's price feed (used in UbiquityPool) to fetch ETH/USD price
     * 4. Curve's Governance-WETH crypto pool to fetch Governance/ETH price
     *
     * There are 2 migrations (deployment scripts):
     * 1. Development (for usage in testnet and local anvil instance)
     * 2. Mainnet (for production usage in mainnet)
     *
     * Development migration deploys (for ease of debugging) mocks of:
     * - Chainlink collateral price feed contract
     * - Chainlink ETH/USD price feed contract
     * - 3CRVLP ERC20 token
     * - WETH token
     * - Curve's Dollar-3CRVLP metapool contract
     * - Curve's Governance-WETH crypto pool contract
     */
    function afterRun() public virtual {
        ManagerFacet managerFacet = ManagerFacet(address(diamond));
        UbiquityPoolFacet ubiquityPoolFacet = UbiquityPoolFacet(
            address(diamond)
        );

        // set threshold to 10 years (3650 days) for ease of debugging
        CHAINLINK_PRICE_FEED_THRESHOLD = 3650 days;

        //========================================
        // Chainlink LUSD/USD price feed deploy
        //========================================

        // start sending owner transactions
        vm.startBroadcast(ownerPrivateKey);

        // deploy LUSD/USD chainlink mock price feed
        chainLinkPriceFeedLusd = new MockChainLinkFeed();

        // stop sending owner transactions
        vm.stopBroadcast();

        //=======================================
        // Chainlink LUSD/USD price feed setup
        //=======================================

        // start sending admin transactions
        vm.startBroadcast(adminPrivateKey);

        // set params for LUSD/USD chainlink price feed mock
        MockChainLinkFeed(address(chainLinkPriceFeedLusd)).updateMockParams(
            1, // round id
            100_000_000, // answer, 100_000_000 = $1.00 (chainlink 8 decimals answer is converted to 6 decimals used in UbiquityPool)
            block.timestamp, // started at
            block.timestamp, // updated at
            1 // answered in round
        );

        // set price feed address and threshold in seconds
        ubiquityPoolFacet.setCollateralChainLinkPriceFeed(
            address(collateralToken), // collateral token address
            address(chainLinkPriceFeedLusd), // price feed address
            CHAINLINK_PRICE_FEED_THRESHOLD // price feed staleness threshold in seconds
        );

        // fetch latest prices from chainlink for collateral with index 0
        ubiquityPoolFacet.updateChainLinkCollateralPrice(0);

        // stop sending admin transactions
        vm.stopBroadcast();

        //=========================================
        // Curve's Dollar-3CRVLP metapool deploy
        //=========================================

        // start sending owner transactions
        vm.startBroadcast(ownerPrivateKey);

        // deploy mock 3CRV-LP token
        curveTriPoolLpToken = new MockERC20(
            "Curve.fi DAI/USDC/USDT",
            "3Crv",
            18
        );

        // deploy mock Curve's Dollar-3CRVLP metapool
        curveDollarMetaPool = new MockCurveStableSwapMetaNG(
            address(dollarToken),
            address(curveTriPoolLpToken)
        );

        // stop sending owner transactions
        vm.stopBroadcast();

        //========================================
        // Curve's Dollar-3CRVLP metapool setup
        //========================================

        // start sending admin transactions
        vm.startBroadcast(adminPrivateKey);

        // set curve's metapool in manager facet
        managerFacet.setStableSwapMetaPoolAddress(address(curveDollarMetaPool));

        // stop sending admin transactions
        vm.stopBroadcast();

        //===========================================
        // Deploy UbiquityAlgorithmicDollarManager
        //===========================================

        // start sending owner transactions
        vm.startBroadcast(ownerPrivateKey);

        ubiquityAlgorithmicDollarManager = new UbiquityAlgorithmicDollarManager(
            ownerAddress
        );

        // stop sending owner transactions
        vm.stopBroadcast();

        //=============================
        // Deploy UbiquityGovernance
        //=============================

        // start sending owner transactions
        vm.startBroadcast(ownerPrivateKey);

        ubiquityGovernance = new UbiquityGovernance(
            address(ubiquityAlgorithmicDollarManager)
        );

        // stop sending owner transactions
        vm.stopBroadcast();

        //==================================
        // UbiquityGovernance token setup
        //==================================

        // start sending admin transactions
        vm.startBroadcast(adminPrivateKey);

        AccessControlFacet accessControlFacet = AccessControlFacet(
            address(diamond)
        );

        // grant diamond Governance token minting and burning rights
        accessControlFacet.grantRole(
            GOVERNANCE_TOKEN_MINTER_ROLE,
            address(diamond)
        );
        accessControlFacet.grantRole(
            GOVERNANCE_TOKEN_BURNER_ROLE,
            address(diamond)
        );

        // set Governance token address in manager facet
        managerFacet.setGovernanceTokenAddress(address(ubiquityGovernance));

        // stop sending admin transactions
        vm.stopBroadcast();

        //=======================================
        // Chainlink ETH/USD price feed deploy
        //=======================================

        // start sending owner transactions
        vm.startBroadcast(ownerPrivateKey);

        // deploy ETH/USD chainlink mock price feed
        chainLinkPriceFeedEth = new MockChainLinkFeed();

        // stop sending owner transactions
        vm.stopBroadcast();

        //======================================
        // Chainlink ETH/USD price feed setup
        //======================================

        // start sending admin transactions
        vm.startBroadcast(adminPrivateKey);

        // set ETH/USD price feed mock params
        MockChainLinkFeed(address(chainLinkPriceFeedEth)).updateMockParams(
            1, // round id
            3000_00000000, // answer, 3000_00000000 = $3000 (8 decimals)
            block.timestamp, // started at
            block.timestamp, // updated at
            1 // answered in round
        );

        // set price feed for ETH/USD pair
        ubiquityPoolFacet.setEthUsdChainLinkPriceFeed(
            address(chainLinkPriceFeedEth), // price feed address
            CHAINLINK_PRICE_FEED_THRESHOLD // price feed staleness threshold in seconds
        );

        // stop sending admin transactions
        vm.stopBroadcast();

        //==============================================
        // Curve's Governance-WETH crypto pool deploy
        //==============================================

        // start sending owner transactions
        vm.startBroadcast(ownerPrivateKey);

        // init mock WETH token
        IERC20 wethToken = new MockERC20("WETH", "WETH", 18);

        // init Curve Governance-WETH crypto pool
        curveGovernanceEthPool = new MockCurveTwocryptoOptimized(
            address(ubiquityGovernance),
            address(wethToken)
        );

        // stop sending owner transactions
        vm.stopBroadcast();

        //=============================================
        // Curve's Governance-WETH crypto pool setup
        //=============================================

        // start sending admin transactions
        vm.startBroadcast(adminPrivateKey);

        // set ETH/Governance price to 30k in Curve pool mock
        MockCurveTwocryptoOptimized(address(curveGovernanceEthPool))
            .updateMockParams(30_000e18);

        // set Governance-ETH pool
        ubiquityPoolFacet.setGovernanceEthPoolAddress(
            address(curveGovernanceEthPool)
        );

        // stop sending admin transactions
        vm.stopBroadcast();
    }
}
