# CurveDollarIncentiveFacet
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/facets/CurveDollarIncentiveFacet.sol)

**Inherits:**
[Modifiers](/src/dollar/libraries/LibAppStorage.sol/contract.Modifiers.md)

Facet adds buy incentive and sell penalty for Curve's Dollar-3CRV MetaPool


## Functions
### incentivize

Adds buy and sell incentives


```solidity
function incentivize(address sender, address receiver, uint256 amountIn) external onlyDollarManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|Sender address|
|`receiver`|`address`|Receiver address|
|`amountIn`|`uint256`|Trade amount|


### setExemptAddress

Sets an address to be exempted from Curve trading incentives


```solidity
function setExemptAddress(address account, bool isExempt) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address to update|
|`isExempt`|`bool`|Flag for whether to flag as exempt or not|


### switchSellPenalty

Switches the sell penalty


```solidity
function switchSellPenalty() external onlyAdmin;
```

### switchBuyIncentive

Switches the buy incentive


```solidity
function switchBuyIncentive() external onlyAdmin;
```

### isSellPenaltyOn

Checks whether sell penalty is enabled


```solidity
function isSellPenaltyOn() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Whether sell penalty is enabled|


### isBuyIncentiveOn

Checks whether buy incentive is enabled


```solidity
function isBuyIncentiveOn() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Whether buy incentive is enabled|


### isExemptAddress

Checks whether `account` is marked as exempt

Whether `account` is exempt from buy incentive and sell penalty


```solidity
function isExemptAddress(address account) external view returns (bool);
```

