# LibDirectGovernanceFarmer
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/libraries/LibDirectGovernanceFarmer.sol)


## State Variables
### DIRECT_GOVERNANCE_STORAGE_POSITION
Storage slot used to store data for this library


```solidity
bytes32 constant DIRECT_GOVERNANCE_STORAGE_POSITION =
    bytes32(uint256(keccak256("ubiquity.contracts.direct.governance.storage")) - 1) & ~bytes32(uint256(0xff));
```


## Functions
### directGovernanceStorage

Returns struct used as a storage for this library


```solidity
function directGovernanceStorage() internal pure returns (DirectGovernanceData storage data);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`data`|`DirectGovernanceData`|Struct used as a storage|


### init

Used to initialize this facet with corresponding values


```solidity
function init(address _manager, address base3Pool, address ubiquity3PoolLP, address _ubiquityDollar, address depositZap)
    internal;
```

### depositSingle

Standard Interface Provided by Curve ///

Deposits a single token to staking

Stable coin (DAI / USDC / USDT / Ubiquity Dollar) => Dollar-3CRV LP => Ubiquity Staking

How it works:
1. User deposit supported stablecoins
2. Deposited stablecoins are added to Curve MetaPool
3. User gets Dollar-3CRV LP tokens
4. Dollar-3CRV LP tokens are transferred to the staking contract
5. User gets a staking share id


```solidity
function depositSingle(address token, uint256 amount, uint256 durationWeeks)
    internal
    returns (uint256 stakingShareId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|Token deposited : Stablecoin|
|`amount`|`uint256`|Amount of tokens to deposit (For max: `uint256(-1)`)|
|`durationWeeks`|`uint256`|Duration in weeks tokens will be locked (1-208)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`stakingShareId`|`uint256`|Staking share id|


### depositMulti

Deposits into Ubiquity protocol

Stable coins (DAI / USDC / USDT / Ubiquity Dollar) => uAD3CRV-f => Ubiquity StakingShare

STEP 1 : Change (DAI / USDC / USDT / Ubiquity dollar) to 3CRV at uAD3CRV MetaPool

STEP 2 : uAD3CRV-f => Ubiquity StakingShare


```solidity
function depositMulti(uint256[4] calldata tokenAmounts, uint256 durationWeeks)
    internal
    returns (uint256 stakingShareId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenAmounts`|`uint256[4]`|Amount of tokens to deposit (For max: `uint256(-1)`) it MUST follow this order [Ubiquity Dollar, DAI, USDC, USDT]|
|`durationWeeks`|`uint256`|Duration in weeks tokens will be locked (1-208)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`stakingShareId`|`uint256`|Staking share id|


### withdrawWithId

Withdraws from Ubiquity protocol

Ubiquity StakingShare => uAD3CRV-f  => stable coin (DAI / USDC / USDT / Ubiquity Dollar)

STEP 1 : Ubiquity StakingShare  => uAD3CRV-f

STEP 2 : uAD3CRV-f => stable coin (DAI / USDC / USDT / Ubiquity Dollar)


```solidity
function withdrawWithId(uint256 stakingShareId) internal returns (uint256[4] memory tokenAmounts);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakingShareId`|`uint256`|Staking Share Id to withdraw|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`tokenAmounts`|`uint256[4]`|Array of token amounts [Ubiquity Dollar, DAI, USDC, USDT]|


### withdraw

Withdraws from Ubiquity protocol

Ubiquity StakingShare => uAD3CRV-f  => stable coin (DAI / USDC / USDT / Ubiquity Dollar)

STEP 1 : Ubiquity StakingShare  => uAD3CRV-f

STEP 2 : uAD3CRV-f => stable coin (DAI / USDC / USDT / Ubiquity Dollar)


```solidity
function withdraw(uint256 stakingShareId, address token) internal returns (uint256 tokenAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakingShareId`|`uint256`|Staking Share Id to withdraw|
|`token`|`address`|Token to withdraw to : DAI, USDC, USDT, 3CRV or Ubiquity Dollar|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`tokenAmount`|`uint256`|Amount of token withdrawn|


### isIdIncluded

Checks whether `id` exists in `idList[]`


```solidity
function isIdIncluded(uint256[] memory idList, uint256 id) internal pure returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`idList`|`uint256[]`|Array to search in|
|`id`|`uint256`|Value to search in `idList`|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Whether `id` exists in `idList[]`|


### isMetaPoolCoin

Checks that `token` is one of the underlying MetaPool tokens or stablecoin from MetaPool


```solidity
function isMetaPoolCoin(address token) internal pure returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|Token address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Whether `token` is one of the underlying MetaPool tokens or stablecoin from MetaPool|


## Events
### DepositSingle
Emitted when user deposits a single token


```solidity
event DepositSingle(
    address indexed sender, address token, uint256 amount, uint256 durationWeeks, uint256 stakingShareId
);
```

### DepositMulti
Emitted when user deposits multiple tokens


```solidity
event DepositMulti(address indexed sender, uint256[4] amounts, uint256 durationWeeks, uint256 stakingShareId);
```

### Withdraw
Emitted when user withdraws a single token


```solidity
event Withdraw(address indexed sender, uint256 stakingShareId, address token, uint256 amount);
```

### WithdrawAll
Emitted when user withdraws multiple tokens


```solidity
event WithdrawAll(address indexed sender, uint256 stakingShareId, uint256[4] amounts);
```

## Structs
### DirectGovernanceData
Struct used as a storage for the current library


```solidity
struct DirectGovernanceData {
    address token0;
    address token1;
    address token2;
    address ubiquity3PoolLP;
    IERC20Ubiquity ubiquityDollar;
    address depositZapUbiquityDollar;
    IUbiquityDollarManager manager;
}
```

