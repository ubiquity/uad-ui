# LibChef
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/libraries/LibChef.sol)

Library for staking Dollar-3CRV LP tokens for Governance tokens reward


## State Variables
### UBIQUITY_CHEF_STORAGE_POSITION
Storage slot used to store data for this library


```solidity
bytes32 constant UBIQUITY_CHEF_STORAGE_POSITION =
    bytes32(uint256(keccak256("diamond.standard.ubiquity.chef.storage")) - 1) & ~bytes32(uint256(0xff));
```


## Functions
### chefStorage

Returns struct used as a storage for this library


```solidity
function chefStorage() internal pure returns (ChefStorage storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`ChefStorage`|Struct used as a storage|


### initialize

Initializes staking


```solidity
function initialize(
    address[] memory _tos,
    uint256[] memory _amounts,
    uint256[] memory _stakingShareIDs,
    uint256 _governancePerBlock
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tos`|`address[]`|Array of addresses for initial deposits|
|`_amounts`|`uint256[]`|Array of LP amounts for initial deposits|
|`_stakingShareIDs`|`uint256[]`|Array of staking share IDs for initial deposits|
|`_governancePerBlock`|`uint256`|Amount of Governance tokens minted each block|


### setGovernancePerBlock

Sets amount of Governance tokens minted each block


```solidity
function setGovernancePerBlock(uint256 _governancePerBlock) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_governancePerBlock`|`uint256`|Amount of Governance tokens minted each block|


### governancePerBlock

Returns amount of Governance tokens minted each block


```solidity
function governancePerBlock() internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of Governance tokens minted each block|


### governanceDivider

Returns governance divider param

Example: if `_governanceDivider = 5` then `100 / 5 = 20%` extra minted Governance tokens for treasury


```solidity
function governanceDivider() internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Governance divider param value|


### pool

Returns pool info


```solidity
function pool() internal view returns (PoolInfo memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`PoolInfo`|Pool info: - last block number when Governance tokens distribution occurred - Governance tokens per share, times 1e12|


### minPriceDiffToUpdateMultiplier

Returns min price difference between the old and the new Dollar prices
required to update the governance multiplier


```solidity
function minPriceDiffToUpdateMultiplier() internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Min Dollar price diff to update the governance multiplier|


### setGovernanceShareForTreasury

Sets Governance token divider param. The bigger `_governanceDivider` the less extra
Governance tokens will be minted for the treasury.

Example: if `_governanceDivider = 5` then `100 / 5 = 20%` extra minted Governance tokens for treasury


```solidity
function setGovernanceShareForTreasury(uint256 _governanceDivider) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_governanceDivider`|`uint256`|Governance divider param value|


### setMinPriceDiffToUpdateMultiplier

Sets min price difference between the old and the new Dollar prices


```solidity
function setMinPriceDiffToUpdateMultiplier(uint256 _minPriceDiffToUpdateMultiplier) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_minPriceDiffToUpdateMultiplier`|`uint256`|Min price diff to update governance multiplier|


### withdraw

Withdraws Dollar-3CRV LP tokens from staking


```solidity
function withdraw(address to, uint256 _amount, uint256 _stakingShareID) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address where to transfer pending Governance token rewards|
|`_amount`|`uint256`|Amount of LP tokens to withdraw|
|`_stakingShareID`|`uint256`|Staking share id|


### getRewards

Withdraws pending Governance token rewards


```solidity
function getRewards(uint256 stakingShareID) internal returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakingShareID`|`uint256`|Staking share id|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Reward amount transferred to `msg.sender`|


### getStakingShareInfo

Returns staking share info


```solidity
function getStakingShareInfo(uint256 _id) internal view returns (uint256[2] memory);
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
function totalShares() internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Total amount of deposited LP tokens|


### pendingGovernance

Returns amount of pending reward Governance tokens


```solidity
function pendingGovernance(uint256 stakingShareID) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakingShareID`|`uint256`|Staking share id|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of pending reward Governance tokens|


### deposit

Deposits Dollar-3CRV LP tokens to staking for Governance tokens allocation


```solidity
function deposit(address to, uint256 _amount, uint256 _stakingShareID) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address where to transfer pending Governance token rewards|
|`_amount`|`uint256`|Amount of LP tokens to deposit|
|`_stakingShareID`|`uint256`|Staking share id|


### _updateGovernanceMultiplier

Updates Governance token multiplier if Dollar price diff > `minPriceDiffToUpdateMultiplier`


```solidity
function _updateGovernanceMultiplier() internal;
```

### _updatePool

Updates reward variables of the given pool to be up-to-date


```solidity
function _updatePool() internal;
```

### _safeGovernanceTransfer

Safe Governance Token transfer function, just in case if rounding
error causes pool not to have enough Governance tokens


```solidity
function _safeGovernanceTransfer(address _to, uint256 _amount) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Address where to transfer Governance tokens|
|`_amount`|`uint256`|Amount of Governance tokens to transfer|


### _getMultiplier

Returns Governance token bonus multiplier based on number of passed blocks


```solidity
function _getMultiplier() internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Governance token bonus multiplier|


### _getGovernanceMultiplier

Returns governance multiplier


```solidity
function _getGovernanceMultiplier() internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Governance multiplier|


## Events
### Deposit
Emitted when Dollar-3CRV LP tokens are deposited to the contract


```solidity
event Deposit(address indexed user, uint256 amount, uint256 indexed stakingShareId);
```

### Withdraw
Emitted when Dollar-3CRV LP tokens are withdrawn from the contract


```solidity
event Withdraw(address indexed user, uint256 amount, uint256 indexed stakingShareId);
```

### GovernancePerBlockModified
Emitted when amount of Governance tokens minted per block is updated


```solidity
event GovernancePerBlockModified(uint256 indexed governancePerBlock);
```

### MinPriceDiffToUpdateMultiplierModified
Emitted when min Dollar price diff for governance multiplier change is updated


```solidity
event MinPriceDiffToUpdateMultiplierModified(uint256 indexed minPriceDiffToUpdateMultiplier);
```

## Structs
### StakingShareInfo
User's staking share info


```solidity
struct StakingShareInfo {
    uint256 amount;
    uint256 rewardDebt;
}
```

### PoolInfo
Pool info


```solidity
struct PoolInfo {
    uint256 lastRewardBlock;
    uint256 accGovernancePerShare;
}
```

### ChefStorage
Struct used as a storage for the current library


```solidity
struct ChefStorage {
    uint256 governancePerBlock;
    uint256 governanceMultiplier;
    uint256 minPriceDiffToUpdateMultiplier;
    uint256 lastPrice;
    uint256 governanceDivider;
    PoolInfo pool;
    mapping(uint256 => StakingShareInfo) ssInfo;
    uint256 totalShares;
}
```

