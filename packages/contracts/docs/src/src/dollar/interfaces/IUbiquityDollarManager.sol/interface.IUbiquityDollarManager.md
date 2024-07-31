# IUbiquityDollarManager
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/interfaces/IUbiquityDollarManager.sol)

**Inherits:**
[IAccessControl](/src/dollar/interfaces/IAccessControl.sol/interface.IAccessControl.md)

Interface for setting protocol parameters


## Functions
### INCENTIVE_MANAGER_ROLE

Returns name for the "incentive manager" role


```solidity
function INCENTIVE_MANAGER_ROLE() external view returns (bytes32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|Bytes representation of the role name|


### GOVERNANCE_TOKEN_MINTER_ROLE

Returns name for the "governance token minter" role


```solidity
function GOVERNANCE_TOKEN_MINTER_ROLE() external view returns (bytes32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|Bytes representation of the role name|


### creditTokenAddress

Returns Credit token address


```solidity
function creditTokenAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Credit token address|


### treasuryAddress

Returns treasury address


```solidity
function treasuryAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Treasury address|


### setTwapOracleAddress

Sets Curve TWAP oracle address


```solidity
function setTwapOracleAddress(address _twapOracleAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_twapOracleAddress`|`address`|TWAP oracle address|


### setCreditTokenAddress

Sets Credit token address


```solidity
function setCreditTokenAddress(address _creditTokenAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_creditTokenAddress`|`address`|Credit token address|


### setCreditNftAddress

Sets Credit NFT address


```solidity
function setCreditNftAddress(address _creditNftAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_creditNftAddress`|`address`|Credit NFT address|


### setIncentiveToDollar

Sets incentive contract `_incentiveAddress` for `_account` address


```solidity
function setIncentiveToDollar(address _account, address _incentiveAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|Address for which to set an incentive contract|
|`_incentiveAddress`|`address`|Incentive contract address|


### setDollarTokenAddress

Sets Dollar token address


```solidity
function setDollarTokenAddress(address _dollarTokenAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dollarTokenAddress`|`address`|Dollar token address|


### setGovernanceTokenAddress

Sets Governance token address


```solidity
function setGovernanceTokenAddress(address _governanceTokenAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_governanceTokenAddress`|`address`|Governance token address|


### setSushiSwapPoolAddress

Sets Sushi swap pool address (Dollar-Governance)


```solidity
function setSushiSwapPoolAddress(address _sushiSwapPoolAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_sushiSwapPoolAddress`|`address`|Pool address|


### setCreditCalculatorAddress

Sets Credit calculator address


```solidity
function setCreditCalculatorAddress(address _creditCalculatorAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_creditCalculatorAddress`|`address`|Credit calculator address|


### setCreditNftCalculatorAddress

Sets Credit NFT calculator address


```solidity
function setCreditNftCalculatorAddress(address _creditNftCalculatorAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_creditNftCalculatorAddress`|`address`|Credit NFT calculator address|


### setDollarMintCalculatorAddress

Sets Dollar mint calculator address


```solidity
function setDollarMintCalculatorAddress(address _dollarMintCalculatorAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dollarMintCalculatorAddress`|`address`|Dollar mint calculator address|


### setExcessDollarsDistributor

Sets excess Dollars distributor address


```solidity
function setExcessDollarsDistributor(address creditNftManagerAddress, address dollarMintExcess) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`creditNftManagerAddress`|`address`|Credit NFT manager address|
|`dollarMintExcess`|`address`|Dollar distributor address|


### setMasterChefAddress

Sets MasterChef address


```solidity
function setMasterChefAddress(address _masterChefAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_masterChefAddress`|`address`|MasterChef address|


### setFormulasAddress

Sets formulas address


```solidity
function setFormulasAddress(address _formulasAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_formulasAddress`|`address`|Formulas address|


### setStakingShareAddress

Sets staking share address


```solidity
function setStakingShareAddress(address _stakingShareAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stakingShareAddress`|`address`|Staking share address|


### setStableSwapMetaPoolAddress

Sets Curve Dollar-3CRV MetaPool address


```solidity
function setStableSwapMetaPoolAddress(address _stableSwapMetaPoolAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stableSwapMetaPoolAddress`|`address`|Curve Dollar-3CRV MetaPool address|


### setStakingContractAddress

Sets staking contract address

*Staking contract participants deposit Curve LP tokens
for a certain duration to earn Governance tokens and more Curve LP tokens*


```solidity
function setStakingContractAddress(address _stakingContractAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stakingContractAddress`|`address`|Staking contract address|


### setTreasuryAddress

Sets treasury address

*Treasury fund is used to maintain the protocol*


```solidity
function setTreasuryAddress(address _treasuryAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_treasuryAddress`|`address`|Treasury address|


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
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_curveFactory`|`address`|Curve MetaPool factory address|
|`_crvBasePool`|`address`|Base pool address for MetaPool|
|`_crv3PoolTokenAddress`|`address`|Curve TriPool address|
|`_amplificationCoefficient`|`uint256`|Amplification coefficient. The smaller it is the closer to a constant product we are.|
|`_fee`|`uint256`|Trade fee, given as an integer with 1e10 precision|


### getExcessDollarsDistributor

Returns excess dollars distributor address


```solidity
function getExcessDollarsDistributor(address _creditNftManagerAddress) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_creditNftManagerAddress`|`address`|Credit NFT manager address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Excess dollars distributor address|


### stakingContractAddress

Returns staking address


```solidity
function stakingContractAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Staking address|


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


### dollarTokenAddress

Returns Dollar token address


```solidity
function dollarTokenAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Dollar token address|


### governanceTokenAddress

Returns Governance token address


```solidity
function governanceTokenAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Governance token address|


