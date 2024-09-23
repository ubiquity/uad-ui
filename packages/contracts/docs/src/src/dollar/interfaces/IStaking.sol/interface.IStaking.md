# IStaking
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/interfaces/IStaking.sol)

Staking interface


## Functions
### deposit

Deposits UbiquityDollar-3CRV LP tokens for a duration to receive staking shares

Weeks act as a multiplier for the amount of staking shares to be received


```solidity
function deposit(uint256 _lpsAmount, uint256 _weeks) external returns (uint256 _id);
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
function addLiquidity(uint256 _amount, uint256 _id, uint256 _weeks) external;
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
function removeLiquidity(uint256 _amount, uint256 _id) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|Amount of LP token deposited when `_id` was created to be withdrawn|
|`_id`|`uint256`|Staking share id|


