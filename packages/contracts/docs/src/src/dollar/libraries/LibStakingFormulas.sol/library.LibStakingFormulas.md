# LibStakingFormulas
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/libraries/LibStakingFormulas.sol)

Library for staking formulas


## Functions
### correctedAmountToWithdraw

Formula to calculate the corrected amount to withdraw based on the proportion of
LP deposited against actual LP tokens in the staking contract

`corrected_amount = amount * (stakingLpBalance / totalLpDeposited)`

If there is more or the same amount of LP than deposited then do nothing


```solidity
function correctedAmountToWithdraw(uint256 _totalLpDeposited, uint256 _stakingLpBalance, uint256 _amount)
    internal
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


### sharesForLP

Formula of governance rights corresponding to a staking shares LP amount

Used on removing liquidity from staking

`shares = (stake.shares * _amount)  / stake.lpAmount`


```solidity
function sharesForLP(StakingShare.Stake memory _stake, uint256[2] memory _shareInfo, uint256 _amount)
    internal
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


### lpRewardsRemoveLiquidityNormalization

Formula may add a decreasing rewards if locking end is near when removing liquidity

`rewards = _amount`


```solidity
function lpRewardsRemoveLiquidityNormalization(StakingShare.Stake memory, uint256[2] memory, uint256 _amount)
    internal
    pure
    returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`StakingShare.Stake`||
|`<none>`|`uint256[2]`||
|`_amount`|`uint256`|Amount of LP tokens|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of LP rewards|


### lpRewardsAddLiquidityNormalization

Formula may add a decreasing rewards if locking end is near when adding liquidity

`rewards = _amount`


```solidity
function lpRewardsAddLiquidityNormalization(StakingShare.Stake memory, uint256[2] memory, uint256 _amount)
    internal
    pure
    returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`StakingShare.Stake`||
|`<none>`|`uint256[2]`||
|`_amount`|`uint256`|Amount of LP tokens|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of LP rewards|


### durationMultiply

Formula duration multiply

`_shares = (1 + _multiplier * _weeks^3/2) * _uLP`

`D32 = D^3/2`

`S = m * D32 * A + A`


```solidity
function durationMultiply(uint256 _uLP, uint256 _weeks, uint256 _multiplier) internal pure returns (uint256 _shares);
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


### bondPrice

Formula staking price


```
IF _totalStakingShares = 0
priceBOND = TARGET_PRICE
ELSE
priceBOND = totalLP / totalShares * TARGET_PRICE
R = T == 0 ? 1 : LP / S
P = R * T
```


```solidity
function bondPrice(uint256 _totalULP, uint256 _totalStakingShares, uint256 _targetPrice)
    internal
    pure
    returns (uint256 _stakingPrice);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_totalULP`|`uint256`|Total LP tokens|
|`_totalStakingShares`|`uint256`|Total staking shares|
|`_targetPrice`|`uint256`|Target Ubiquity Dollar price|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_stakingPrice`|`uint256`|Staking share price|


### governanceMultiply

Formula Governance token multiply


```
new_multiplier = multiplier * (1.05 / (1 + abs(1 - price)))
nM = M * C / A
A = (1 + abs(1 - P)))
5 >= multiplier >= 0.2
```


```solidity
function governanceMultiply(uint256 _multiplier, uint256 _price) internal pure returns (uint256 _newMultiplier);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_multiplier`|`uint256`|Initial Governance token min multiplier|
|`_price`|`uint256`|Current share price|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_newMultiplier`|`uint256`|New Governance token min multiplier|


