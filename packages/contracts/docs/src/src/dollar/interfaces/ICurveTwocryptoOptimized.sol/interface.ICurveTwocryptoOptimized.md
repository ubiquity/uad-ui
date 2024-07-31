# ICurveTwocryptoOptimized
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/interfaces/ICurveTwocryptoOptimized.sol)

**Inherits:**
[ICurveStableSwapMetaNG](/src/dollar/interfaces/ICurveStableSwapMetaNG.sol/interface.ICurveStableSwapMetaNG.md)

Curve's CurveTwocryptoOptimized interface

*Differences between Curve's crypto and stable swap meta pools (and how Ubiquity organization uses them):
1. They contain different tokens:
a) Curve's stable swap metapool contains Dollar/3CRVLP pair
b) Curve's crypto pool contains Governance/ETH pair
2. They use different bonding curve shapes:
a) Curve's stable swap metapool is more straight (because underlying tokens are pegged to USD)
b) Curve's crypto pool resembles Uniswap's bonding curve (because underlying tokens are not USD pegged)
3. The `price_oracle()` method works differently:
a) Curve's stable swap metapool `price_oracle(uint256 i)` accepts coin index parameter
b) Curve's crypto pool `price_oracle()` doesn't accept coin index parameter and always returns oracle price for coin at index 1*

*Basically `ICurveTwocryptoOptimized` has the same interface as `ICurveStableSwapMetaNG`
but we distinguish them in the code for clarity.*


## Functions
### price_oracle

Getter for the oracle price of the coin at index 1 with regard to the coin at index 0.
The price oracle is an exponential moving average with a periodicity determined by `ma_time`.


```solidity
function price_oracle() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Price oracle|


