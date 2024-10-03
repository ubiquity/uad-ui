# LibDollarMintExcess
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/libraries/LibDollarMintExcess.sol)

Library for distributing excess Dollars when `mintClaimableDollars()` is called

Excess Dollars are distributed this way:
- 50% goes to the treasury address
- 10% goes for burning Dollar-Governance LP tokens in a DEX pool
- 40% goes to the Staking contract


## State Variables
### _minAmountToDistribute
Min amount of Dollars to distribute


```solidity
uint256 private constant _minAmountToDistribute = 100 ether;
```


### _router
DEX router address


```solidity
IUniswapV2Router01 private constant _router = IUniswapV2Router01(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);
```


## Functions
### distributeDollars

Distributes excess Dollars:
- 50% goes to the treasury address
- 10% goes for burning Dollar-Governance LP tokens in a DEX pool
- 40% goes to the Staking contract


```solidity
function distributeDollars() internal;
```

### _swapDollarsForGovernance

Swaps Dollars for Governance tokens in a DEX


```solidity
function _swapDollarsForGovernance(bytes16 amountIn) internal returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amountIn`|`bytes16`|Amount of Dollars to swap|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of Governance tokens returned|


### _governanceBuyBackLPAndBurn

Swaps half of `amount` Dollars for Governance tokens and adds
them as a liquidity to a DEX pool burning the result LP tokens


```solidity
function _governanceBuyBackLPAndBurn(uint256 amount) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Amount of Dollars|


### _convertToCurveLPAndTransfer

Swaps `amount` Dollars for 3CRV LP tokens in the MetaPool, adds
3CRV LP tokens to the MetaPool and transfers the result Dollar-3CRV LP tokens
to the Staking contract


```solidity
function _convertToCurveLPAndTransfer(uint256 amount) internal returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Dollars amount|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of Dollar-3CRV LP tokens minted|


