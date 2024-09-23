# DirectGovernanceFarmerFacet
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/facets/DirectGovernanceFarmerFacet.sol)

**Inherits:**
[Modifiers](/src/dollar/libraries/LibAppStorage.sol/contract.Modifiers.md)

Simpler Staking Facet

How it works:
1. User sends stablecoins (DAI / USDC / USDT / Dollar)
2. Deposited stablecoins are added to Dollar-3CRV Curve MetaPool
3. User gets Dollar-3CRV LP tokens
4. Dollar-3CRV LP tokens are transferred to the staking contract
5. User gets a staking share id


## Functions
### initialize

it works as a constructor to set contract values at storage


```solidity
function initialize(
    address _manager,
    address base3Pool,
    address ubiquity3PoolLP,
    address _ubiquityDollar,
    address zapPool
) public onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_manager`|`address`|Ubiquity Manager|
|`base3Pool`|`address`|Base3Pool Address|
|`ubiquity3PoolLP`|`address`|Ubiquity3PoolLP Address|
|`_ubiquityDollar`|`address`|Ubiquity Dollar Address|
|`zapPool`|`address`|ZapPool Address|


### depositSingle

Deposits a single token to staking

Stable coin (DAI / USDC / USDT / Ubiquity Dollar) => Dollar-3CRV LP => Ubiquity Staking

How it works:
1. User sends stablecoins (DAI / USDC / USDT / Dollar)
2. Deposited stablecoins are added to Dollar-3CRV Curve MetaPool
3. User gets Dollar-3CRV LP tokens
4. Dollar-3CRV LP tokens are transferred to the staking contract
5. User gets a staking share id


```solidity
function depositSingle(address token, uint256 amount, uint256 durationWeeks)
    external
    nonReentrant
    returns (uint256 stakingShareId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|Token deposited : DAI, USDC, USDT or Ubiquity Dollar|
|`amount`|`uint256`|Amount of tokens to deposit (For max: `uint256(-1)`)|
|`durationWeeks`|`uint256`|Duration in weeks tokens will be locked (1-208)|


### depositMulti

Deposits into Ubiquity protocol

Stable coins (DAI / USDC / USDT / Ubiquity Dollar) => uAD3CRV-f => Ubiquity StakingShare

STEP 1 : Change (DAI / USDC / USDT / Ubiquity dollar) to 3CRV at uAD3CRV MetaPool

STEP 2 : uAD3CRV-f => Ubiquity StakingShare


```solidity
function depositMulti(uint256[4] calldata tokenAmounts, uint256 durationWeeks)
    external
    nonReentrant
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


### withdrawId

Withdraws from Ubiquity protocol

Ubiquity StakingShare => uAD3CRV-f  => stable coin (DAI / USDC / USDT / Ubiquity Dollar)

STEP 1 : Ubiquity StakingShare  => uAD3CRV-f

STEP 2 : uAD3CRV-f => stable coin (DAI / USDC / USDT / Ubiquity Dollar)


```solidity
function withdrawId(uint256 stakingShareId) external nonReentrant returns (uint256[4] memory tokenAmounts);
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
function withdraw(uint256 stakingShareId, address token) external nonReentrant returns (uint256 tokenAmount);
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
function isIdIncluded(uint256[] memory idList, uint256 id) external pure returns (bool);
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

Helper function that checks that `token` is one of the underlying MetaPool tokens or stablecoin from MetaPool


```solidity
function isMetaPoolCoin(address token) external pure returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|Token address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Whether `token` is one of the underlying MetaPool tokens or stablecoin from MetaPool|


