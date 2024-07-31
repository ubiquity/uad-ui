# IUbiquityChef
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/interfaces/IUbiquityChef.sol)

Interface for staking Dollar-3CRV LP tokens for Governance tokens reward


## Functions
### deposit

Deposits Dollar-3CRV LP tokens to staking for Governance tokens allocation


```solidity
function deposit(address sender, uint256 amount, uint256 stakingShareID) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|Address where to transfer pending Governance token rewards|
|`amount`|`uint256`|Amount of LP tokens to deposit|
|`stakingShareID`|`uint256`|Staking share id|


### withdraw

Withdraws Dollar-3CRV LP tokens from staking


```solidity
function withdraw(address sender, uint256 amount, uint256 stakingShareID) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|Address where to transfer pending Governance token rewards|
|`amount`|`uint256`|Amount of LP tokens to withdraw|
|`stakingShareID`|`uint256`|Staking share id|


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


### pendingGovernance

Returns amount of pending reward Governance tokens


```solidity
function pendingGovernance(address _user) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`|User address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of pending reward Governance tokens|


## Events
### Deposit
Emitted when Dollar-3CRV LP tokens are deposited to the contract


```solidity
event Deposit(address indexed user, uint256 amount, uint256 stakingShareID);
```

### Withdraw
Emitted when Dollar-3CRV LP tokens are withdrawn from the contract


```solidity
event Withdraw(address indexed user, uint256 amount, uint256 stakingShareID);
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

