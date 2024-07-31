# LibStaking
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/libraries/LibStaking.sol)

Staking library


## State Variables
### STAKING_CONTROL_STORAGE_SLOT
Storage slot used to store data for this library


```solidity
bytes32 constant STAKING_CONTROL_STORAGE_SLOT =
    bytes32(uint256(keccak256("ubiquity.contracts.staking.storage")) - 1) & ~bytes32(uint256(0xff));
```


## Functions
### stakingStorage

Returns struct used as a storage for this library


```solidity
function stakingStorage() internal pure returns (StakingData storage l);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`l`|`StakingData`|Struct used as a storage|


### dollarPriceReset

Removes Ubiquity Dollar unilaterally from the curve LP share sitting inside
the staking contract and sends the Ubiquity Dollar received to the treasury. This will
have the immediate effect of pushing the Ubiquity Dollar price HIGHER

It will remove one coin only from the curve LP share sitting in the staking contract


```solidity
function dollarPriceReset(uint256 amount) internal;
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
function crvPriceReset(uint256 amount) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Amount of LP token to be removed for 3CRV tokens|


### setStakingDiscountMultiplier

Sets staking discount multiplier


```solidity
function setStakingDiscountMultiplier(uint256 _stakingDiscountMultiplier) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stakingDiscountMultiplier`|`uint256`|New staking discount multiplier|


### stakingDiscountMultiplier

Returns staking discount multiplier


```solidity
function stakingDiscountMultiplier() internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Staking discount multiplier|


### blockCountInAWeek

Returns number of blocks in a week


```solidity
function blockCountInAWeek() internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Number of blocks in a week|


### setBlockCountInAWeek

Sets number of blocks in a week


```solidity
function setBlockCountInAWeek(uint256 _blockCountInAWeek) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_blockCountInAWeek`|`uint256`|Number of blocks in a week|


### deposit

Deposits UbiquityDollar-3CRV LP tokens for a duration to receive staking shares

Weeks act as a multiplier for the amount of staking shares to be received


```solidity
function deposit(uint256 _lpsAmount, uint256 _weeks) internal returns (uint256 _id);
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
function addLiquidity(uint256 _amount, uint256 _id, uint256 _weeks) internal;
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
function removeLiquidity(uint256 _amount, uint256 _id) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|Amount of LP token deposited when `_id` was created to be withdrawn|
|`_id`|`uint256`|Staking share id|


### pendingLpRewards

View function to see pending LP rewards on frontend


```solidity
function pendingLpRewards(uint256 _id) internal view returns (uint256);
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
function lpRewardForShares(uint256 amount, uint256 lpRewardDebt) internal view returns (uint256 pendingLpReward);
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
function currentShareValue() internal view returns (uint256 priceShare);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`priceShare`|`uint256`|Share price|


### _updateLpPerShare

Updates the accumulated excess LP per share


```solidity
function _updateLpPerShare() internal;
```

### _mint

Mints a staking share on deposit


```solidity
function _mint(address to, uint256 lpAmount, uint256 shares, uint256 endBlock) internal returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address where to mint a staking share|
|`lpAmount`|`uint256`|Amount of LP tokens|
|`shares`|`uint256`|Amount of shares|
|`endBlock`|`uint256`|Staking share end block|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Staking share id|


### _checkForLiquidity

Returns staking share info


```solidity
function _checkForLiquidity(uint256 _id)
    internal
    view
    returns (uint256[2] memory bs, StakingShare.Stake memory stake);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_id`|`uint256`|Staking share id|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`bs`|`uint256[2]`|Array of amount of shares and reward debt|
|`stake`|`StakingShare.Stake`|Stake info|


## Events
### PriceReset
Emitted when Dollar or 3CRV tokens are removed from Curve MetaPool


```solidity
event PriceReset(address _tokenWithdrawn, uint256 _amountWithdrawn, uint256 _amountTransferred);
```

### Deposit
Emitted when user deposits Dollar-3CRV LP tokens to the staking contract


```solidity
event Deposit(
    address indexed _user,
    uint256 indexed _id,
    uint256 _lpAmount,
    uint256 _stakingShareAmount,
    uint256 _weeks,
    uint256 _endBlock
);
```

### RemoveLiquidityFromStake
Emitted when user removes liquidity from stake


```solidity
event RemoveLiquidityFromStake(
    address indexed _user,
    uint256 indexed _id,
    uint256 _lpAmount,
    uint256 _lpAmountTransferred,
    uint256 _lpRewards,
    uint256 _stakingShareAmount
);
```

### AddLiquidityFromStake
Emitted when user adds liquidity to stake


```solidity
event AddLiquidityFromStake(address indexed _user, uint256 indexed _id, uint256 _lpAmount, uint256 _stakingShareAmount);
```

### StakingDiscountMultiplierUpdated
Emitted when staking discount multiplier is updated


```solidity
event StakingDiscountMultiplierUpdated(uint256 _stakingDiscountMultiplier);
```

### BlockCountInAWeekUpdated
Emitted when number of blocks in week is updated


```solidity
event BlockCountInAWeekUpdated(uint256 _blockCountInAWeek);
```

## Structs
### StakingData
Struct used as a storage for the current library


```solidity
struct StakingData {
    uint256 stakingDiscountMultiplier;
    uint256 blockCountInAWeek;
    uint256 accLpRewardPerShare;
    uint256 lpRewards;
    uint256 totalLpToMigrate;
}
```

