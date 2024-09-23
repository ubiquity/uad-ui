# ICreditRedemptionCalculator
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/interfaces/ICreditRedemptionCalculator.sol)

Contract interface for calculating amount of Credits to mint on Dollars burn

Users are allowed to burn Dollars in exchange for Credit tokens. When a new debt
cycle starts (i.e. Dollar price < 1$) then users can burn Dollars for Credits via this
formula: `y = x * ((BlockDebtStart / BlockBurn) ^ p)` where:
- `y`: amount of Credits to mint
- `x`: amount of Dollars to burn
- `BlockDebtStart`: block number when debt cycle started (i.e. block number when Dollar price became < 1$)
- `BlockBurn`: block number when Dollar burn operation is performed
- `p`: DAO controlled variable. The greater the `p` param the harsher the decrease rate of Dollars to mint.

Example:
1. Block debt cycle start: 190, block burn: 200, p: 1, Dollars to burn: 300
2. Credits to mint: `300 * ((190/200)^1) = 285`

Example:
1. Block debt cycle start: 100, block burn: 200, p: 1, Dollars to burn: 300
2. Credits to mint: `300 * ((100/200)^1) = 150`

Example:
1. Block debt cycle start: 190, block burn: 200, p: 2, Dollars to burn: 300
2. Credits to mint: `300 * ((190/200)^1) = 270`

Example:
1. Block debt cycle start: 100, block burn: 200, p: 2, Dollars to burn: 300
2. Credits to mint: `300 * ((100/200)^1) = 75`

It is more profitable to burn Dollars for Credits at the beginning of the debt cycle.


## Functions
### getCreditAmount

Returns amount of Credits to mint for `dollarsToBurn` amount of Dollars to burn


```solidity
function getCreditAmount(uint256 dollarsToBurn, uint256 blockHeightDebt) external view returns (uint256);
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


