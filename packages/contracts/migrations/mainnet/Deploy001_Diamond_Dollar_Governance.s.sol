// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/interfaces/AggregatorV3Interface.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Deploy001_Diamond_Dollar_Governance as Deploy001_Diamond_Dollar_Governance_Development} from "../development/Deploy001_Diamond_Dollar_Governance.s.sol";
import {UbiquityAlgorithmicDollarManager} from "../../src/deprecated/UbiquityAlgorithmicDollarManager.sol";
import {UbiquityGovernance} from "../../src/deprecated/UbiquityGovernance.sol";
import {ManagerFacet} from "../../src/dollar/facets/ManagerFacet.sol";
import {UbiquityPoolFacet} from "../../src/dollar/facets/UbiquityPoolFacet.sol";
import {ICurveStableSwapFactoryNG} from "../../src/dollar/interfaces/ICurveStableSwapFactoryNG.sol";
import {ICurveStableSwapMetaNG} from "../../src/dollar/interfaces/ICurveStableSwapMetaNG.sol";

/// @notice Migration contract
contract Deploy001_Diamond_Dollar_Governance is
    Deploy001_Diamond_Dollar_Governance_Development
{
    function run() public override {
        // Run migration for testnet because "Deploy001_Diamond_Dollar_Governance" migration
        // is identical both for testnet/development and mainnet
        super.run();
    }

    /**
     * @notice Runs before the main `run()` method
     *
     * @dev Initializes collateral token
     * @dev Collateral token is different for mainnet and development:
     * - mainnet: uses LUSD address from `COLLATERAL_TOKEN_ADDRESS` env variables
     * - development: deploys mocked ERC20 token from scratch
     */
    function beforeRun() public override {
        // read env variables
        address collateralTokenAddress = vm.envAddress(
            "COLLATERAL_TOKEN_ADDRESS"
        );

        //=================================
        // Collateral ERC20 token setup
        //=================================

        // use existing LUSD contract for mainnet
        collateralToken = IERC20(collateralTokenAddress);
    }

    /**
     * @notice Runs after the main `run()` method
     *
     * @dev Initializes:
     * - oracle related contracts
     * - Governance token related contracts
     *
     * @dev We override `afterRun()` from `Deploy001_Diamond_Dollar_Governance_Development` because
     * we need to use already deployed contracts while `Deploy001_Diamond_Dollar_Governance_Development`
     * deploys all oracle and Governance token related contracts from scratch for ease of debugging.
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
     * Mainnet (i.e. production) migration uses already deployed contracts for:
     * - Chainlink collateral price feed contract
     * - UbiquityAlgorithmicDollarManager contract
     * - UbiquityGovernance token contract
     */
    function afterRun() public override {
        // read env variables
        address chainlinkPriceFeedAddress = vm.envAddress(
            "COLLATERAL_TOKEN_CHAINLINK_PRICE_FEED_ADDRESS"
        );

        //=======================================
        // Chainlink LUSD/USD price feed setup
        //=======================================

        // start sending admin transactions
        vm.startBroadcast(adminPrivateKey);

        // set threshold to 1 day
        CHAINLINK_PRICE_FEED_THRESHOLD = 1 days;

        // init LUSD/USD chainlink price feed
        chainLinkPriceFeedLusd = AggregatorV3Interface(
            chainlinkPriceFeedAddress
        );

        UbiquityPoolFacet ubiquityPoolFacet = UbiquityPoolFacet(
            address(diamond)
        );

        // set price feed
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

        // deploy Curve Dollar-3CRV metapool
        address curveDollarMetaPoolAddress = ICurveStableSwapFactoryNG(
            0x6A8cbed756804B16E05E741eDaBd5cB544AE21bf
        ).deploy_metapool(
                0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7, // Curve 3pool (DAI-USDT-USDC) address
                "Dollar/3CRV", // pool name
                "Dollar3CRV", // LP token symbol
                address(dollarToken), // main token
                100, // amplification coefficient
                40000000, // trade fee, 0.04%
                20000000000, // off-peg fee multiplier
                2597, // moving average time value, 2597 = 1800 seconds
                0, // metapool implementation index
                0, // asset type
                "", // method id for oracle asset type (not applicable for Dollar)
                address(0) // token oracle address (not applicable for Dollar)
            );

        // stop sending owner transactions
        vm.stopBroadcast();

        //========================================
        // Curve's Dollar-3CRVLP metapool setup
        //========================================

        // start sending admin transactions
        vm.startBroadcast(adminPrivateKey);

        // set curve's metapool in manager facet
        ManagerFacet managerFacet = ManagerFacet(address(diamond));
        managerFacet.setStableSwapMetaPoolAddress(curveDollarMetaPoolAddress);

        // stop sending admin transactions
        vm.stopBroadcast();

        //==========================================
        // UbiquityAlgorithmicDollarManager setup
        //==========================================

        // using already deployed (on mainnet) UbiquityAlgorithmicDollarManager
        ubiquityAlgorithmicDollarManager = UbiquityAlgorithmicDollarManager(
            0x4DA97a8b831C345dBe6d16FF7432DF2b7b776d98
        );

        //============================
        // UbiquityGovernance setup
        //============================

        // using already deployed (on mainnet) Governance token
        ubiquityGovernance = UbiquityGovernance(
            0x4e38D89362f7e5db0096CE44ebD021c3962aA9a0
        );
    }
}
