# StakingFacet
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/facets/StakingFacet.sol)

**Inherits:**
[Modifiers](/src/dollar/libraries/LibAppStorage.sol/contract.Modifiers.md), [IStaking](/src/dollar/interfaces/IStaking.sol/interface.IStaking.md)

Staking facet


## Functions
### dollarPriceReset

Removes Ubiquity Dollar unilaterally from the curve LP share sitting inside
the staking contract and sends the Ubiquity Dollar received to the treasury. This will
have the immediate effect of pushing the Ubiquity Dollar price HIGHER

It will remove one coin only from the curve LP share sitting in the staking contract


```solidity
function dollarPriceReset(uint256 amount) external onlyStakingManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Amount of LP token to be removed for Ubiquity Dollar|


### crvPriceReset

Remove 3CRV unilaterally from the curve LP share sitting inside
the staking contract and send the 3CRV received to the treasury. This will
have the immediate effect of pushing the Ubiquity Dollar price LOWER.

It will remove one coin only from the curve LP share sitting in the staking contract


```solidity
function crvPriceReset(uint256 amount) external onlyStakingManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Amount of LP token to be removed for 3CRV tokens|


### setStakingDiscountMultiplier

Sets staking discount multiplier


```solidity
function setStakingDiscountMultiplier(uint256 _stakingDiscountMultiplier) external onlyStakingManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stakingDiscountMultiplier`|`uint256`|New staking discount multiplier|


### stakingDiscountMultiplier

Returns staking discount multiplier


```solidity
function stakingDiscountMultiplier() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Staking discount multiplier|


### blockCountInAWeek

Returns number of blocks in a week


```solidity
function blockCountInAWeek() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Number of blocks in a week|


### setBlockCountInAWeek

Sets number of blocks in a week


```solidity
function setBlockCountInAWeek(uint256 _blockCountInAWeek) external onlyStakingManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_blockCountInAWeek`|`uint256`|Number of blocks in a week|


### deposit

Deposits UbiquityDollar-3CRV LP tokens for a duration to receive staking shares

Weeks act as a multiplier for the amount of staking shares to be received


```solidity
function deposit(uint256 _lpsAmount, uint256 _weeks) external whenNotPaused returns (uint256 _id);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_lpsAmount`|`uint256`|Amount of LP tokens to send|
|`_weeks`|`uint256`|Number of weeks during which LP tokens will be held|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_id`|`uint256`|Staking share id|


### addLiquidity

Adds an amount of UbiquityDollar-3CRV LP tokens

Staking shares are ERC1155 (aka NFT) because they have an expiration date


```solidity
function addLiquidity(uint256 _amount, uint256 _id, uint256 _weeks) external whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|Amount of LP token to deposit|
|`_id`|`uint256`|Staking share id|
|`_weeks`|`uint256`|Number of weeks during which LP tokens will be held|


### removeLiquidity

Removes an amount of UbiquityDollar-3CRV LP tokens

Staking shares are ERC1155 (aka NFT) because they have an expiration date


```solidity
function removeLiquidity(uint256 _amount, uint256 _id) external whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|Amount of LP token deposited when `_id` was created to be withdrawn|
|`_id`|`uint256`|Staking share id|


### pendingLpRewards

View function to see pending LP rewards on frontend


```solidity
function pendingLpRewards(uint256 _id) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_id`|`uint256`|Staking share id|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of LP rewards|


### lpRewardForShares

Returns the amount of LP token rewards an amount of shares entitled


```solidity
function lpRewardForShares(uint256 amount, uint256 lpRewardDebt) external view returns (uint256 pendingLpReward);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Amount of staking shares|
|`lpRewardDebt`|`uint256`|Amount of LP rewards that have already been distributed|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`pendingLpReward`|`uint256`|Amount of pending LP rewards|


### currentShareValue

Returns current share price


```solidity
function currentShareValue() external view returns (uint256 priceShare);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`priceShare`|`uint256`|Share price|


