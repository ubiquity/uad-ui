# IUbiquityFormulas
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/interfaces/IUbiquityFormulas.sol)

Interface for staking formulas


## Functions
### durationMultiply

Formula duration multiply

`_shares = (1 + _multiplier * _weeks^3/2) * _uLP`

`D32 = D^3/2`

`S = m * D32 * A + A`


```solidity
function durationMultiply(uint256 _uLP, uint256 _weeks, uint256 _multiplier) external pure returns (uint256 _shares);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_uLP`|`uint256`|Amount of LP tokens|
|`_weeks`|`uint256`|Minimum duration of staking period|
|`_multiplier`|`uint256`|Staking discount multiplier = 0.0001|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_shares`|`uint256`|Amount of shares|


### correctedAmountToWithdraw

Formula to calculate the corrected amount to withdraw based on the proportion of
LP deposited against actual LP tokens in the staking contract

`corrected_amount = amount * (stakingLpBalance / totalLpDeposited)`

If there is more or the same amount of LP than deposited then do nothing


```solidity
function correctedAmountToWithdraw(uint256 _totalLpDeposited, uint256 _stakingLpBalance, uint256 _amount)
    external
    pure
    returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_totalLpDeposited`|`uint256`|Total amount of LP deposited by users|
|`_stakingLpBalance`|`uint256`|Actual staking contract LP tokens balance minus LP rewards|
|`_amount`|`uint256`|Amount of LP tokens|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of LP tokens to redeem|


### lpRewardsAddLiquidityNormalization

Formula may add a decreasing rewards if locking end is near when adding liquidity

`rewards = _amount`


```solidity
function lpRewardsAddLiquidityNormalization(
    StakingShare.Stake memory _stake,
    uint256[2] memory _shareInfo,
    uint256 _amount
) external pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stake`|`StakingShare.Stake`|Stake info of staking share|
|`_shareInfo`|`uint256[2]`|Array of share amounts|
|`_amount`|`uint256`|Amount of LP tokens|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of LP rewards|


### lpRewardsRemoveLiquidityNormalization

Formula may add a decreasing rewards if locking end is near when removing liquidity

`rewards = _amount`


```solidity
function lpRewardsRemoveLiquidityNormalization(
    StakingShare.Stake memory _stake,
    uint256[2] memory _shareInfo,
    uint256 _amount
) external pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stake`|`StakingShare.Stake`|Stake info of staking share|
|`_shareInfo`|`uint256[2]`|Array of share amounts|
|`_amount`|`uint256`|Amount of LP tokens|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of LP rewards|


### sharesForLP

Formula of governance rights corresponding to a staking shares LP amount

Used on removing liquidity from staking

`shares = (stake.shares * _amount)  / stake.lpAmount`


```solidity
function sharesForLP(StakingShare.Stake memory _stake, uint256[2] memory _shareInfo, uint256 _amount)
    external
    pure
    returns (uint256 _uLP);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stake`|`StakingShare.Stake`|Stake info of staking share|
|`_shareInfo`|`uint256[2]`|Array of share amounts|
|`_amount`|`uint256`|Amount of LP tokens|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_uLP`|`uint256`|Amount of shares|


