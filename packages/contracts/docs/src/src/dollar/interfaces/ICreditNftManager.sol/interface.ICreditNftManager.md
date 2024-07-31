# ICreditNftManager
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/interfaces/ICreditNftManager.sol)

**Inherits:**
IERC1155Receiver

Interface for basic credit issuing and redemption mechanism for Credit NFT and Credit holders

Allows users to burn their Dollars in exchange for Credit NFTs or Credits redeemable in the future

Allows users to:
- redeem individual Credit NFT or batch redeem Credit NFT on a first-come first-serve basis
- redeem Credits for Dollars

*Implements `IERC1155Receiver` so that it can deal with redemptions*


## Functions
### redeemCreditNft

Burns Credit NFTs for Dollars when Dollar price > 1$


```solidity
function redeemCreditNft(uint256 id, uint256 amount) external returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`uint256`|Credit NFT expiry block number|
|`amount`|`uint256`|Amount of Credit NFTs to burn|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of unredeemed Credit NFTs|


### exchangeDollarsForCreditNft

Burns Dollars in exchange for Credit NFTs

Should only be called when Dollar price < 1$


```solidity
function exchangeDollarsForCreditNft(uint256 amount) external returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Amount of Dollars to exchange for Credit NFTs|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Expiry block number when Credit NFTs can no longer be redeemed for Dollars|


