# ManagerFacet
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/facets/ManagerFacet.sol)

**Inherits:**
[Modifiers](/src/dollar/libraries/LibAppStorage.sol/contract.Modifiers.md)

Facet for setting protocol parameters


## Functions
### setCreditTokenAddress

Sets Credit token address


```solidity
function setCreditTokenAddress(address _creditTokenAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_creditTokenAddress`|`address`|Credit token address|


### setDollarTokenAddress

Sets Dollar token address


```solidity
function setDollarTokenAddress(address _dollarTokenAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dollarTokenAddress`|`address`|Dollar token address|


### setUbiquistickAddress

Sets UbiquiStick address


```solidity
function setUbiquistickAddress(address _ubiquistickAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ubiquistickAddress`|`address`|UbiquiStick address|


### setCreditNftAddress

Sets Credit NFT address


```solidity
function setCreditNftAddress(address _creditNftAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_creditNftAddress`|`address`|Credit NFT address|


### setGovernanceTokenAddress

Sets Governance token address


```solidity
function setGovernanceTokenAddress(address _governanceTokenAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_governanceTokenAddress`|`address`|Governance token address|


### setSushiSwapPoolAddress

Sets Sushi swap pool address (Dollar-Governance)


```solidity
function setSushiSwapPoolAddress(address _sushiSwapPoolAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_sushiSwapPoolAddress`|`address`|Pool address|


### setDollarMintCalculatorAddress

Sets Dollar mint calculator address


```solidity
function setDollarMintCalculatorAddress(address _dollarMintCalculatorAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dollarMintCalculatorAddress`|`address`|Dollar mint calculator address|


### setExcessDollarsDistributor

Sets excess Dollars distributor address


```solidity
function setExcessDollarsDistributor(address creditNftManagerAddress, address dollarMintExcess) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`creditNftManagerAddress`|`address`|Credit NFT manager address|
|`dollarMintExcess`|`address`|Dollar distributor address|


### setMasterChefAddress

Sets MasterChef address


```solidity
function setMasterChefAddress(address _masterChefAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_masterChefAddress`|`address`|MasterChef address|


### setFormulasAddress

Sets formulas address


```solidity
function setFormulasAddress(address _formulasAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_formulasAddress`|`address`|Formulas address|


### setStakingShareAddress

Sets staking share address


```solidity
function setStakingShareAddress(address _stakingShareAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stakingShareAddress`|`address`|Staking share address|


### setCurveDollarIncentiveAddress

Sets Curve Dollar incentive address


```solidity
function setCurveDollarIncentiveAddress(address _curveDollarIncentiveAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_curveDollarIncentiveAddress`|`address`|Curve Dollar incentive address|


### setStableSwapMetaPoolAddress

Sets Curve Dollar-3CRV MetaPool address


```solidity
function setStableSwapMetaPoolAddress(address _stableSwapMetaPoolAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stableSwapMetaPoolAddress`|`address`|Curve Dollar-3CRV MetaPool address|


### setStableSwapPlainPoolAddress

Sets Curve's Dollar-Stablecoin plain pool address

*`_stableSwapPlainPoolAddress` is used to fetch Dollar price in USD*


```solidity
function setStableSwapPlainPoolAddress(address _stableSwapPlainPoolAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stableSwapPlainPoolAddress`|`address`|Curve's Dollar-Stablecoin plain pool address|


### setStakingContractAddress

Sets staking contract address

*Staking contract participants deposit Curve LP tokens
for a certain duration to earn Governance tokens and more Curve LP tokens*


```solidity
function setStakingContractAddress(address _stakingContractAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stakingContractAddress`|`address`|Staking contract address|


### setBondingCurveAddress

Sets bonding curve address used for UbiquiStick minting


```solidity
function setBondingCurveAddress(address _bondingCurveAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_bondingCurveAddress`|`address`|Bonding curve address|


### setBancorFormulaAddress

Sets bancor formula address

*Implied to be used for UbiquiStick minting*


```solidity
function setBancorFormulaAddress(address _bancorFormulaAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_bancorFormulaAddress`|`address`|Bancor formula address|


### setTreasuryAddress

Sets treasury address

*Treasury fund is used to maintain the protocol*


```solidity
function setTreasuryAddress(address _treasuryAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_treasuryAddress`|`address`|Treasury address|


### setIncentiveToDollar

Sets incentive contract `_incentiveAddress` for `_account` address


```solidity
function setIncentiveToDollar(address _account, address _incentiveAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|Address for which to set an incentive contract|
|`_incentiveAddress`|`address`|Incentive contract address|


### deployStableSwapPool

Deploys Curve MetaPool [Stablecoin, 3CRV LP]

*From the curve documentation for uncollateralized algorithmic
stablecoins amplification should be 5-10*


```solidity
function deployStableSwapPool(
    address _curveFactory,
    address _crvBasePool,
    address _crv3PoolTokenAddress,
    uint256 _amplificationCoefficient,
    uint256 _fee
) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_curveFactory`|`address`|Curve MetaPool factory address|
|`_crvBasePool`|`address`|Base pool address for MetaPool|
|`_crv3PoolTokenAddress`|`address`|Curve TriPool address|
|`_amplificationCoefficient`|`uint256`|Amplification coefficient. The smaller it is the closer to a constant product we are.|
|`_fee`|`uint256`|Trade fee, given as an integer with 1e10 precision|


### twapOracleAddress

Returns Curve TWAP oracle address


```solidity
function twapOracleAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Curve TWAP oracle address|


### dollarTokenAddress

Returns Dollar token address


```solidity
function dollarTokenAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Dollar token address|


### ubiquiStickAddress

Returns UbiquiStick address


```solidity
function ubiquiStickAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|UbiquiStick address|


### creditTokenAddress

Returns Credit token address


```solidity
function creditTokenAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Credit token address|


### creditNftAddress

Returns Credit NFT address


```solidity
function creditNftAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Credit NFT address|


### governanceTokenAddress

Returns Governance token address


```solidity
function governanceTokenAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Governance token address|


### sushiSwapPoolAddress

Returns Sushi swap pool address for Dollar-Governance pair


```solidity
function sushiSwapPoolAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Pool address|


### creditCalculatorAddress

Returns Credit redemption calculator address


```solidity
function creditCalculatorAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Credit redemption calculator address|


### creditNftCalculatorAddress

Returns Credit NFT redemption calculator address


```solidity
function creditNftCalculatorAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Credit NFT redemption calculator address|


### dollarMintCalculatorAddress

Returns Dollar mint calculator address


```solidity
function dollarMintCalculatorAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Dollar mint calculator address|


### excessDollarsDistributor

Returns Dollar distributor address


```solidity
function excessDollarsDistributor(address _creditNftManagerAddress) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_creditNftManagerAddress`|`address`|Credit NFT manager address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Dollar distributor address|


### masterChefAddress

Returns MasterChef address


```solidity
function masterChefAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|MasterChef address|


### formulasAddress

Returns formulas address


```solidity
function formulasAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Formulas address|


### stakingShareAddress

Returns staking share address


```solidity
function stakingShareAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Staking share address|


### stableSwapMetaPoolAddress

Returns Curve MetaPool address for Dollar-3CRV LP pair


```solidity
function stableSwapMetaPoolAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Curve MetaPool address|


### stableSwapPlainPoolAddress

Returns Curve's plain pool address for Dollar-Stablecoin pair


```solidity
function stableSwapPlainPoolAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Curve's plain pool address for Dollar-Stablecoin pair|


### stakingContractAddress

Returns staking address


```solidity
function stakingContractAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Staking address|


### bondingCurveAddress

Returns bonding curve address used for UbiquiStick minting


```solidity
function bondingCurveAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Bonding curve address|


### bancorFormulaAddress

Returns Bancor formula address

*Implied to be used for UbiquiStick minting*


```solidity
function bancorFormulaAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Bancor formula address|


### treasuryAddress

Returns treasury address


```solidity
function treasuryAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Treasury address|


### curve3PoolTokenAddress

Returns Curve TriPool 3CRV LP token address


```solidity
function curve3PoolTokenAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Curve TriPool 3CRV LP token address|


