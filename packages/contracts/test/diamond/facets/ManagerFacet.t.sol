// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../DiamondTestSetup.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ICurveFactory} from "../../../src/dollar/interfaces/ICurveFactory.sol";
import {ICurveStableSwapMetaNG} from "../../../src/dollar/interfaces/ICurveStableSwapMetaNG.sol";
import {LibAccessControl} from "../../../src/dollar/libraries/LibAccessControl.sol";
import {MockCurveStableSwapMetaNG} from "../../../src/dollar/mocks/MockCurveStableSwapMetaNG.sol";
import {MockERC20} from "../../../src/dollar/mocks/MockERC20.sol";
import {MockCurveFactory} from "../../../src/dollar/mocks/MockCurveFactory.sol";

contract ManagerFacetTest is DiamondTestSetup {
    function testCanCallGeneralFunctions_ShouldSucceed() public view {
        managerFacet.excessDollarsDistributor(contract1);
    }

    function testSetTwapOracleAddress_ShouldSucceed() public prankAs(admin) {
        assertEq(managerFacet.twapOracleAddress(), address(diamond));
    }

    function testSetDollarTokenAddress_ShouldSucceed() public prankAs(admin) {
        assertEq(managerFacet.dollarTokenAddress(), address(dollarToken));
    }

    function testSetCreditTokenAddress_ShouldSucceed() public prankAs(admin) {
        managerFacet.setCreditTokenAddress(contract1);
        assertEq(managerFacet.creditTokenAddress(), contract1);
    }

    function testSetCreditNftAddress_ShouldSucceed() public prankAs(admin) {
        managerFacet.setCreditNftAddress(contract1);
        assertEq(managerFacet.creditNftAddress(), contract1);
    }

    function testSetGovernanceTokenAddress_ShouldSucceed()
        public
        prankAs(admin)
    {
        managerFacet.setGovernanceTokenAddress(contract1);
        assertEq(managerFacet.governanceTokenAddress(), contract1);
    }

    function testSetSushiSwapPoolAddress_ShouldSucceed() public prankAs(admin) {
        managerFacet.setSushiSwapPoolAddress(contract1);
        assertEq(managerFacet.sushiSwapPoolAddress(), contract1);
    }

    function testSetDollarMintCalculatorAddress_ShouldSucceed()
        public
        prankAs(admin)
    {
        managerFacet.setDollarMintCalculatorAddress(contract1);
        assertEq(managerFacet.dollarMintCalculatorAddress(), contract1);
    }

    function testSetExcessDollarsDistributor_ShouldSucceed()
        public
        prankAs(admin)
    {
        managerFacet.setExcessDollarsDistributor(contract1, contract2);
        assertEq(managerFacet.excessDollarsDistributor(contract1), contract2);
    }

    function testSetMasterChefAddress_ShouldSucceed() public prankAs(admin) {
        managerFacet.setMasterChefAddress(contract1);
        assertEq(managerFacet.masterChefAddress(), contract1);
    }

    function testSetFormulasAddress_ShouldSucceed() public prankAs(admin) {
        managerFacet.setFormulasAddress(contract1);
        assertEq(managerFacet.formulasAddress(), contract1);
    }

    function testSetStakingShareAddress_ShouldSucceed() public prankAs(admin) {
        managerFacet.setStakingShareAddress(contract1);
        assertEq(managerFacet.stakingShareAddress(), contract1);
    }

    function testSetStableSwapMetaPoolAddress_ShouldSucceed()
        public
        prankAs(admin)
    {
        managerFacet.setStableSwapMetaPoolAddress(contract1);
        assertEq(managerFacet.stableSwapMetaPoolAddress(), contract1);
    }

    function testSetStableSwapPlainPoolAddress_ShouldSucceed()
        public
        prankAs(admin)
    {
        managerFacet.setStableSwapPlainPoolAddress(contract1);
        assertEq(managerFacet.stableSwapPlainPoolAddress(), contract1);
    }

    function testSetStakingContractAddress_ShouldSucceed()
        public
        prankAs(admin)
    {
        managerFacet.setStakingContractAddress(contract1);
        assertEq(managerFacet.stakingContractAddress(), contract1);
    }

    function testSetTreasuryAddress_ShouldSucceed() public prankAs(admin) {
        managerFacet.setTreasuryAddress(contract1);
        assertEq(managerFacet.treasuryAddress(), contract1);
    }

    function testSetMinterRoleWhenInitializing_ShouldSucceed()
        public
        prankAs(admin)
    {
        assertEq(
            accessControlFacet.hasRole(GOVERNANCE_TOKEN_MINTER_ROLE, admin),
            true
        );
    }

    function testInitializeDollarTokenAddress_ShouldSucceed()
        public
        prankAs(admin)
    {
        assertEq(managerFacet.dollarTokenAddress(), address(dollarToken));
    }

    function testDeployStableSwapPool_ShouldSucceed() public {
        assertEq(dollarToken.decimals(), 18);
        vm.startPrank(admin);

        dollarToken.mint(admin, 10000);

        MockERC20 curve3CrvToken = new MockERC20("3 CRV", "3CRV", 18);
        address secondAccount = address(0x3);
        address stakingZeroAccount = address(0x4);
        address stakingMinAccount = address(0x5);
        address stakingMaxAccount = address(0x6);

        address[6] memory mintings = [
            admin,
            address(diamond),
            secondAccount,
            stakingZeroAccount,
            stakingMinAccount,
            stakingMaxAccount
        ];

        for (uint256 i = 0; i < mintings.length; ++i) {
            deal(address(dollarToken), mintings[i], 10000e18);
        }

        address stakingV1Address = generateAddress("stakingV1", true, 10 ether);
        accessControlFacet.grantRole(
            GOVERNANCE_TOKEN_MINTER_ROLE,
            stakingV1Address
        );
        accessControlFacet.grantRole(
            GOVERNANCE_TOKEN_BURNER_ROLE,
            stakingV1Address
        );

        vm.stopPrank();

        address[4] memory crvDeal = [
            address(diamond),
            stakingMaxAccount,
            stakingMinAccount,
            secondAccount
        ];

        // curve3CrvBasePool Curve.fi: DAI/USDC/USDT Pool
        // curve3CrvToken  TokenTracker that represents  Curve.fi DAI/USDC/USDT part in the pool  (3Crv)

        for (uint256 i; i < crvDeal.length; ++i) {
            // distribute crv to the accounts
            curve3CrvToken.mint(crvDeal[i], 10000e18);
        }

        vm.startPrank(admin);

        ICurveFactory curvePoolFactory = ICurveFactory(new MockCurveFactory());
        address curve3CrvBasePool = address(
            new MockCurveStableSwapMetaNG(
                address(diamond),
                address(curve3CrvToken)
            )
        );
        managerFacet.deployStableSwapPool(
            address(curvePoolFactory),
            curve3CrvBasePool,
            address(curve3CrvToken),
            10,
            50000000
        );

        ICurveStableSwapMetaNG metapool = ICurveStableSwapMetaNG(
            managerFacet.stableSwapMetaPoolAddress()
        );
        address stakingV2Address = generateAddress("stakingV2", true, 10 ether);
        metapool.transfer(address(stakingV2Address), 100e18);
        vm.stopPrank();
    }
}
