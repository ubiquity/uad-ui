# IUbiquityDollarToken
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/interfaces/IUbiquityDollarToken.sol)

**Inherits:**
[IERC20Ubiquity](/src/dollar/interfaces/IERC20Ubiquity.sol/interface.IERC20Ubiquity.md)

Ubiquity Dollar token interface


## Functions
### setIncentiveContract

Sets `incentive` contract for `account`

Incentive contracts are applied on Dollar transfers:
- EOA => contract
- contract => EOA
- contract => contract
- any transfer global incentive


```solidity
function setIncentiveContract(address account, address incentive) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Account to incentivize|
|`incentive`|`address`|Incentive contract address|


### incentiveContract

Returns incentive contract address for `account`

*Address is 0 if there is no incentive contract for the account*


```solidity
function incentiveContract(address account) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address for which we should retrieve an incentive contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Incentive contract address|


## Events
### IncentiveContractUpdate
Emitted on setting an incentive contract for an account


```solidity
event IncentiveContractUpdate(address indexed _incentivized, address indexed _incentiveContract);
```

