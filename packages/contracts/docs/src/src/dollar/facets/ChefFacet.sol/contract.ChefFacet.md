# ChefFacet
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/facets/ChefFacet.sol)

**Inherits:**
[Modifiers](/src/dollar/libraries/LibAppStorage.sol/contract.Modifiers.md)

Contract facet for staking Dollar-3CRV LP tokens for Governance tokens reward


## Functions
### setGovernancePerBlock

Sets amount of Governance tokens minted each block


```solidity
function setGovernancePerBlock(uint256 _governancePerBlock) external onlyTokenManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_governancePerBlock`|`uint256`|Amount of Governance tokens minted each block|


### setGovernanceShareForTreasury

Sets Governance token divider param. The bigger `_governanceDivider` the less extra
Governance tokens will be minted for the treasury.

Example: if `_governanceDivider = 5` then `100 / 5 = 20%` extra minted Governance tokens for treasury


```solidity
function setGovernanceShareForTreasury(uint256 _governanceDivider) external onlyTokenManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_governanceDivider`|`uint256`|Governance divider param value|


### setMinPriceDiffToUpdateMultiplier

Sets min price difference between the old and the new Dollar prices


```solidity
function setMinPriceDiffToUpdateMultiplier(uint256 _minPriceDiffToUpdateMultiplier) external onlyTokenManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_minPriceDiffToUpdateMultiplier`|`uint256`|Min price diff to update governance multiplier|


### getRewards

Withdraws pending Governance token rewards


```solidity
function getRewards(uint256 stakingShareID) external returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakingShareID`|`uint256`|Staking share id|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Reward amount transferred to `msg.sender`|


### governanceMultiplier

Returns governance multiplier


```solidity
function governanceMultiplier() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Governance multiplier|


### governancePerBlock

Returns amount of Governance tokens minted each block


```solidity
function governancePerBlock() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of Governance tokens minted each block|


### governanceDivider

Returns governance divider param

Example: if `_governanceDivider = 5` then `100 / 5 = 20%` extra minted Governance tokens for treasury


```solidity
function governanceDivider() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Governance divider param value|


### pool

Returns pool info


```solidity
function pool() external view returns (uint256, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Last block number when Governance tokens distribution occurred|
|`<none>`|`uint256`|Accumulated Governance tokens per share, times 1e12|


### minPriceDiffToUpdateMultiplier

Returns min price difference between the old and the new Dollar prices
required to update the governance multiplier


```solidity
function minPriceDiffToUpdateMultiplier() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Min Dollar price diff to update the governance multiplier|


### pendingGovernance

Returns amount of pending reward Governance tokens


```solidity
function pendingGovernance(uint256 stakingShareID) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakingShareID`|`uint256`|Staking share id|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of pending reward Governance tokens|


### getStakingShareInfo

Returns staking share info


```solidity
function getStakingShareInfo(uint256 _id) external view returns (uint256[2] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_id`|`uint256`|Staking share id|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[2]`|Array of amount of shares and reward debt|


### totalShares

Total amount of Dollar-3CRV LP tokens deposited to the Staking contract


```solidity
function totalShares() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Total amount of deposited LP tokens|


