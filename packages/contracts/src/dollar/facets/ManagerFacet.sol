// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Modifiers} from "../libraries/LibAppStorage.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../dollar/interfaces/IUbiquityDollarToken.sol";
import "../../dollar/interfaces/ICurveFactory.sol";
import "../../dollar/interfaces/ICurveStableSwapMetaNG.sol";
import "../libraries/LibAccessControl.sol";

/**
 * @notice Facet for setting protocol parameters
 */
contract ManagerFacet is Modifiers {
    /**
     * @notice Sets Credit token address
     * @param _creditTokenAddress Credit token address
     */
    function setCreditTokenAddress(
        address _creditTokenAddress
    ) external onlyAdmin {
        store.creditTokenAddress = _creditTokenAddress;
    }

    /**
     * @notice Sets Dollar token address
     * @param _dollarTokenAddress Dollar token address
     */
    function setDollarTokenAddress(
        address _dollarTokenAddress
    ) external onlyAdmin {
        store.dollarTokenAddress = _dollarTokenAddress;
    }

    /**
     * @notice Sets UbiquiStick address
     * @param _ubiquistickAddress UbiquiStick address
     */
    function setUbiquistickAddress(
        address _ubiquistickAddress
    ) external onlyAdmin {
        store.ubiquiStickAddress = _ubiquistickAddress;
    }

    /**
     * @notice Sets Credit NFT address
     * @param _creditNftAddress Credit NFT address
     */
    function setCreditNftAddress(address _creditNftAddress) external onlyAdmin {
        store.creditNftAddress = _creditNftAddress;
    }

    /**
     * @notice Sets Governance token address
     * @param _governanceTokenAddress Governance token address
     */
    function setGovernanceTokenAddress(
        address _governanceTokenAddress
    ) external onlyAdmin {
        store.governanceTokenAddress = _governanceTokenAddress;
    }

    /**
     * @notice Sets Sushi swap pool address (Dollar-Governance)
     * @param _sushiSwapPoolAddress Pool address
     */
    function setSushiSwapPoolAddress(
        address _sushiSwapPoolAddress
    ) external onlyAdmin {
        store.sushiSwapPoolAddress = _sushiSwapPoolAddress;
    }

    /**
     * @notice Sets Dollar mint calculator address
     * @param _dollarMintCalculatorAddress Dollar mint calculator address
     */
    function setDollarMintCalculatorAddress(
        address _dollarMintCalculatorAddress
    ) external onlyAdmin {
        store.dollarMintCalculatorAddress = _dollarMintCalculatorAddress;
    }

    /**
     * @notice Sets excess Dollars distributor address
     * @param creditNftManagerAddress Credit NFT manager address
     * @param dollarMintExcess Dollar distributor address
     */
    function setExcessDollarsDistributor(
        address creditNftManagerAddress,
        address dollarMintExcess
    ) external onlyAdmin {
        store._excessDollarDistributors[
            creditNftManagerAddress
        ] = dollarMintExcess;
    }

    /**
     * @notice Sets MasterChef address
     * @param _masterChefAddress MasterChef address
     */
    function setMasterChefAddress(
        address _masterChefAddress
    ) external onlyAdmin {
        store.masterChefAddress = _masterChefAddress;
    }

    /**
     * @notice Sets formulas address
     * @param _formulasAddress Formulas address
     */
    function setFormulasAddress(address _formulasAddress) external onlyAdmin {
        store.formulasAddress = _formulasAddress;
    }

    /**
     * @notice Sets staking share address
     * @param _stakingShareAddress Staking share address
     */
    function setStakingShareAddress(
        address _stakingShareAddress
    ) external onlyAdmin {
        store.stakingShareAddress = _stakingShareAddress;
    }

    /**
     * @notice Sets Curve Dollar incentive address
     * @param _curveDollarIncentiveAddress Curve Dollar incentive address
     */
    function setCurveDollarIncentiveAddress(
        address _curveDollarIncentiveAddress
    ) external onlyAdmin {
        store.curveDollarIncentiveAddress = _curveDollarIncentiveAddress;
    }

    /**
     * @notice Sets Curve Dollar-3CRV MetaPool address
     * @param _stableSwapMetaPoolAddress Curve Dollar-3CRV MetaPool address
     */
    function setStableSwapMetaPoolAddress(
        address _stableSwapMetaPoolAddress
    ) external onlyAdmin {
        store.stableSwapMetaPoolAddress = _stableSwapMetaPoolAddress;
    }

    /**
     * @notice Sets Curve's Dollar-Stablecoin plain pool address
     * @dev `_stableSwapPlainPoolAddress` is used to fetch Dollar price in USD
     * @param _stableSwapPlainPoolAddress Curve's Dollar-Stablecoin plain pool address
     */
    function setStableSwapPlainPoolAddress(
        address _stableSwapPlainPoolAddress
    ) external onlyAdmin {
        store.stableSwapPlainPoolAddress = _stableSwapPlainPoolAddress;
    }

    /**
     * @notice Sets staking contract address
     * @dev Staking contract participants deposit Curve LP tokens
     * for a certain duration to earn Governance tokens and more Curve LP tokens
     * @param _stakingContractAddress Staking contract address
     */
    function setStakingContractAddress(
        address _stakingContractAddress
    ) external onlyAdmin {
        store.stakingContractAddress = _stakingContractAddress;
    }

    /**
     * @notice Sets bonding curve address used for UbiquiStick minting
     * @param _bondingCurveAddress Bonding curve address
     */
    function setBondingCurveAddress(
        address _bondingCurveAddress
    ) external onlyAdmin {
        store.bondingCurveAddress = _bondingCurveAddress;
    }

    /**
     * @notice Sets bancor formula address
     * @dev Implied to be used for UbiquiStick minting
     * @param _bancorFormulaAddress Bancor formula address
     */
    function setBancorFormulaAddress(
        address _bancorFormulaAddress
    ) external onlyAdmin {
        store.bancorFormulaAddress = _bancorFormulaAddress;
    }

    /**
     * @notice Sets treasury address
     * @dev Treasury fund is used to maintain the protocol
     * @param _treasuryAddress Treasury address
     */
    function setTreasuryAddress(address _treasuryAddress) external onlyAdmin {
        store.treasuryAddress = _treasuryAddress;
    }

    /**
     * @notice Sets incentive contract `_incentiveAddress` for `_account` address
     * @param _account Address for which to set an incentive contract
     * @param _incentiveAddress Incentive contract address
     */
    function setIncentiveToDollar(
        address _account,
        address _incentiveAddress
    ) external onlyAdmin {
        IUbiquityDollarToken dollar = IUbiquityDollarToken(
            store.dollarTokenAddress
        );
        dollar.setIncentiveContract(_account, _incentiveAddress);
    }

    /**
     * @notice Deploys Curve MetaPool [Stablecoin, 3CRV LP]
     * @dev  From the curve documentation for uncollateralized algorithmic
     * stablecoins amplification should be 5-10
     * @param _curveFactory Curve MetaPool factory address
     * @param _crvBasePool Base pool address for MetaPool
     * @param _crv3PoolTokenAddress Curve TriPool address
     * @param _amplificationCoefficient Amplification coefficient. The smaller
     * it is the closer to a constant product we are.
     * @param _fee Trade fee, given as an integer with 1e10 precision
     */
    function deployStableSwapPool(
        address _curveFactory,
        address _crvBasePool,
        address _crv3PoolTokenAddress,
        uint256 _amplificationCoefficient,
        uint256 _fee
    ) external onlyAdmin {
        // Create new StableSwap meta pool (Dollar <-> 3Crv)
        // slither-disable-next-line reentrancy-no-eth
        address metaPool = ICurveFactory(_curveFactory).deploy_metapool(
            _crvBasePool,
            ERC20(store.dollarTokenAddress).name(),
            ERC20(store.dollarTokenAddress).symbol(),
            store.dollarTokenAddress,
            _amplificationCoefficient,
            _fee
        );
        store.stableSwapMetaPoolAddress = metaPool;
        // Approve the newly-deployed meta pool to transfer this contract's funds
        uint256 crv3PoolTokenAmount = IERC20(_crv3PoolTokenAddress).balanceOf(
            address(this)
        );
        uint256 dollarTokenAmount = IERC20(store.dollarTokenAddress).balanceOf(
            address(this)
        );
        // safe approve revert if approve from non-zero to non-zero allowance
        IERC20(_crv3PoolTokenAddress).approve(metaPool, 0);
        IERC20(_crv3PoolTokenAddress).approve(metaPool, crv3PoolTokenAmount);

        IERC20(store.dollarTokenAddress).approve(metaPool, 0);
        IERC20(store.dollarTokenAddress).approve(metaPool, dollarTokenAmount);

        // coin at index 0 is Dollar and index 1 is 3CRV
        require(
            ICurveStableSwapMetaNG(metaPool).coins(0) ==
                store.dollarTokenAddress &&
                ICurveStableSwapMetaNG(metaPool).coins(1) ==
                _crv3PoolTokenAddress,
            "MGR: COIN_ORDER_MISMATCH"
        );
        // Add the initial liquidity to the StableSwap meta pool
        uint256[2] memory amounts = [
            IERC20(store.dollarTokenAddress).balanceOf(address(this)),
            IERC20(_crv3PoolTokenAddress).balanceOf(address(this))
        ];
        // set curve 3Pool address
        store.curve3PoolTokenAddress = _crv3PoolTokenAddress;
        ICurveStableSwapMetaNG(metaPool).add_liquidity(amounts, 0, msg.sender);
    }

    /**
     * @notice Returns Curve TWAP oracle address
     * @return Curve TWAP oracle address
     */
    function twapOracleAddress() external view returns (address) {
        return address(this);
    }

    /**
     * @notice Returns Dollar token address
     * @return Dollar token address
     */
    function dollarTokenAddress() external view returns (address) {
        return store.dollarTokenAddress;
    }

    /**
     * @notice Returns UbiquiStick address
     * @return UbiquiStick address
     */
    function ubiquiStickAddress() external view returns (address) {
        return store.ubiquiStickAddress;
    }

    /**
     * @notice Returns Credit token address
     * @return Credit token address
     */
    function creditTokenAddress() external view returns (address) {
        return store.creditTokenAddress;
    }

    /**
     * @notice Returns Credit NFT address
     * @return Credit NFT address
     */
    function creditNftAddress() external view returns (address) {
        return store.creditNftAddress;
    }

    /**
     * @notice Returns Governance token address
     * @return Governance token address
     */
    function governanceTokenAddress() external view returns (address) {
        return store.governanceTokenAddress;
    }

    /**
     * @notice Returns Sushi swap pool address for Dollar-Governance pair
     * @return Pool address
     */
    function sushiSwapPoolAddress() external view returns (address) {
        return store.sushiSwapPoolAddress;
    }

    /**
     * @notice Returns Credit redemption calculator address
     * @return Credit redemption calculator address
     */
    function creditCalculatorAddress() external view returns (address) {
        return address(this);
    }

    /**
     * @notice Returns Credit NFT redemption calculator address
     * @return Credit NFT redemption calculator address
     */
    function creditNftCalculatorAddress() external view returns (address) {
        return address(this);
    }

    /**
     * @notice Returns Dollar mint calculator address
     * @return Dollar mint calculator address
     */
    function dollarMintCalculatorAddress() external view returns (address) {
        return store.dollarMintCalculatorAddress;
    }

    /**
     * @notice Returns Dollar distributor address
     * @param _creditNftManagerAddress Credit NFT manager address
     * @return Dollar distributor address
     */
    function excessDollarsDistributor(
        address _creditNftManagerAddress
    ) external view returns (address) {
        return store._excessDollarDistributors[_creditNftManagerAddress];
    }

    /**
     * @notice Returns MasterChef address
     * @return MasterChef address
     */
    function masterChefAddress() external view returns (address) {
        return store.masterChefAddress;
    }

    /**
     * @notice Returns formulas address
     * @return Formulas address
     */
    function formulasAddress() external view returns (address) {
        return store.formulasAddress;
    }

    /**
     * @notice Returns staking share address
     * @return Staking share address
     */
    function stakingShareAddress() external view returns (address) {
        return store.stakingShareAddress;
    }

    /**
     * @notice Returns Curve MetaPool address for Dollar-3CRV LP pair
     * @return Curve MetaPool address
     */
    function stableSwapMetaPoolAddress() external view returns (address) {
        return store.stableSwapMetaPoolAddress;
    }

    /**
     * @notice Returns Curve's plain pool address for Dollar-Stablecoin pair
     * @return Curve's plain pool address for Dollar-Stablecoin pair
     */
    function stableSwapPlainPoolAddress() external view returns (address) {
        return store.stableSwapPlainPoolAddress;
    }

    /**
     * @notice Returns staking address
     * @return Staking address
     */
    function stakingContractAddress() external view returns (address) {
        return store.stakingContractAddress;
    }

    /**
     * @notice Returns bonding curve address used for UbiquiStick minting
     * @return Bonding curve address
     */
    function bondingCurveAddress() external view returns (address) {
        return store.bondingCurveAddress;
    }

    /**
     * @notice Returns Bancor formula address
     * @dev Implied to be used for UbiquiStick minting
     * @return Bancor formula address
     */
    function bancorFormulaAddress() external view returns (address) {
        return store.bancorFormulaAddress;
    }

    /**
     * @notice Returns treasury address
     * @return Treasury address
     */
    function treasuryAddress() external view returns (address) {
        return store.treasuryAddress;
    }

    /**
     * @notice Returns Curve TriPool 3CRV LP token address
     * @return Curve TriPool 3CRV LP token address
     */
    function curve3PoolTokenAddress() external view returns (address) {
        return store.curve3PoolTokenAddress;
    }
}
