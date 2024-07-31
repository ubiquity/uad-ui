# ICreditNftRedemptionCalculator
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/interfaces/ICreditNftRedemptionCalculator.sol)

Contract interface for calculating amount of Credit NFTs to mint on Dollars burn

Users can burn their Dollars in exchange for Credit NFTs which are minted with a premium.
Premium is calculated with the following formula: `1 / ((1 - R) ^ 2) - 1` where `R` represents Credit NFT
total oustanding debt divived by Dollar total supply. When users burn Dollars and mint Credit NFTs then
total oustading debt of Credit NFT is increased. On the contrary, when Credit NFTs are burned then
Credit NFT total oustanding debt is decreased.

Example:
1. Dollar total supply: 10_000, Credit NFT total oustanding debt: 100, User burns: 200 Dollars
2. When user burns 200 Dollars then `200 + 200 * (1 / ((1 - (100 / 10_000)) ^ 2) - 1) = ~204.06` Credit NFTs are minted

Example:
1. Dollar total supply: 10_000, Credit NFT total oustanding debt: 9_000, User burns: 200 Dollars
2. When user burns 200 Dollars then `200 + 200 * (1 / ((1 - (9_000 / 10_000)) ^ 2) - 1) = 20_000` Credit NFTs are minted

So the more Credit NFT oustanding debt (i.e. Credit NFT total supply) the more premium applied for minting Credit NFTs

*1 Credit NFT = 1 whole Ubiquity Dollar, not 1 wei*


## Functions
### getCreditNftAmount

Returns Credit NFT amount minted for `dollarsToBurn` amount of Dollars to burn


```solidity
function getCreditNftAmount(uint256 dollarsToBurn) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`dollarsToBurn`|`uint256`|Amount of Dollars to burn|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of Credit NFTs to mint|


