# CreditRedemptionCalculatorFacet
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/facets/CreditRedemptionCalculatorFacet.sol)

**Inherits:**
[Modifiers](/src/dollar/libraries/LibAppStorage.sol/contract.Modifiers.md), [ICreditRedemptionCalculator](/src/dollar/interfaces/ICreditRedemptionCalculator.sol/interface.ICreditRedemptionCalculator.md)

Contract facet for calculating amount of Credits to mint on Dollars burn


## Functions
### setConstant

Sets the `p` param in the Credit mint calculation formula:
`y = x * ((BlockDebtStart / BlockBurn) ^ p)`


```solidity
function setConstant(uint256 coef) external onlyIncentiveAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`coef`|`uint256`|New `p` param in wei|


### getConstant

Returns the `p` param used in the Credit mint calculation formula


```solidity
function getConstant() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|`p` param|


### getCreditAmount

Returns amount of Credits to mint for `dollarsToBurn` amount of Dollars to burn


```solidity
function getCreditAmount(uint256 dollarsToBurn, uint256 blockHeightDebt) external view override returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`dollarsToBurn`|`uint256`|Amount of Dollars to burn|
|`blockHeightDebt`|`uint256`|Block number when the latest debt cycle started (i.e. when Dollar price became < 1$)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of Credits to mint|


