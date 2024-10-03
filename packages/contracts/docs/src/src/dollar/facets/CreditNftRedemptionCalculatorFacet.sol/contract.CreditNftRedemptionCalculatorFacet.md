# CreditNftRedemptionCalculatorFacet
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/facets/CreditNftRedemptionCalculatorFacet.sol)

**Inherits:**
[ICreditNftRedemptionCalculator](/src/dollar/interfaces/ICreditNftRedemptionCalculator.sol/interface.ICreditNftRedemptionCalculator.md)

Contract facet for calculating amount of Credit NFTs to mint on Dollars burn


## Functions
### getCreditNftAmount

Returns Credit NFT amount minted for `dollarsToBurn` amount of Dollars to burn


```solidity
function getCreditNftAmount(uint256 dollarsToBurn) external view override returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`dollarsToBurn`|`uint256`|Amount of Dollars to burn|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of Credit NFTs to mint|


