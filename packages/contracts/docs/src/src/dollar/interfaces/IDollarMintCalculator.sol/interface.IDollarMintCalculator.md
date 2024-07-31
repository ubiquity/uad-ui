# IDollarMintCalculator
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/interfaces/IDollarMintCalculator.sol)

Interface for calculating amount of Dollars to be minted

When Dollar price > 1$ then any user can call `mintClaimableDollars()` to mint Dollars
in order to move Dollar token to 1$ peg. The amount of Dollars to be minted is calculated
using this formula `(TWAP_PRICE - 1) * DOLLAR_TOTAL_SUPPLY`.

Example:
1. Dollar price (i.e. TWAP price): 1.1$, Dollar total supply: 10_000
2. When `mintClaimableDollars()` is called then `(1.1 - 1) * 10_000 = 1000` Dollars are minted
to the current contract.


## Functions
### getDollarsToMint

Returns amount of Dollars to be minted based on formula `(TWAP_PRICE - 1) * DOLLAR_TOTAL_SUPPLY`


```solidity
function getDollarsToMint() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of Dollars to be minted|


