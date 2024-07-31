# LibCreditNftManager
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/libraries/LibCreditNftManager.sol)

Library for basic credit issuing and redemption mechanism for Credit NFT and Credit holders

Allows users to burn their Dollars in exchange for Credit NFTs or Credits redeemable in the future

Allows users to:
- redeem individual Credit NFT or batch redeem Credit NFT on a first-come first-serve basis
- redeem Credits for Dollars


## State Variables
### CREDIT_NFT_MANAGER_STORAGE_SLOT
Storage slot used to store data for this library


```solidity
bytes32 constant CREDIT_NFT_MANAGER_STORAGE_SLOT =
    bytes32(uint256(keccak256("ubiquity.contracts.credit.nft.manager.storage")) - 1) & ~bytes32(uint256(0xff));
```


## Functions
### creditNftStorage

Returns struct used as a storage for this library


```solidity
function creditNftStorage() internal pure returns (CreditNftManagerData storage l);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`l`|`CreditNftManagerData`|Struct used as a storage|


### expiredCreditNftConversionRate

Returns Credit NFT to Governance conversion rate


```solidity
function expiredCreditNftConversionRate() internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Conversion rate|


### setExpiredCreditNftConversionRate

Credit NFT to Governance conversion rate

When Credit NFTs are expired they can be converted to
Governance tokens using `rate` conversion rate


```solidity
function setExpiredCreditNftConversionRate(uint256 rate) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`rate`|`uint256`|Credit NFT to Governance tokens conversion rate|


### setCreditNftLength

Sets Credit NFT block lifespan


```solidity
function setCreditNftLength(uint256 _creditNftLengthBlocks) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_creditNftLengthBlocks`|`uint256`|The number of blocks during which Credit NFTs can be redeemed for Dollars|


### creditNftLengthBlocks

Returns Credit NFT block lifespan


```solidity
function creditNftLengthBlocks() internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Number of blocks during which Credit NFTs can be redeemed for Dollars|


### exchangeDollarsForCreditNft

Burns Dollars in exchange for Credit NFTs

Should only be called when Dollar price < 1$


```solidity
function exchangeDollarsForCreditNft(uint256 amount) internal returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Amount of Dollars to exchange for Credit NFTs|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Expiry block number when Credit NFTs can no longer be redeemed for Dollars|


### exchangeDollarsForCredit

Burns Dollars in exchange for Credit tokens

Should only be called when Dollar price < 1$


```solidity
function exchangeDollarsForCredit(uint256 amount) internal returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Amount of Dollars to burn|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of Credits minted|


### getCreditNftReturnedForDollars

Returns amount of Credit NFTs to be minted for the `amount` of Dollars to burn


```solidity
function getCreditNftReturnedForDollars(uint256 amount) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Amount of Dollars to burn|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of Credit NFTs to be minted|


### getCreditReturnedForDollars

Returns the amount of Credit tokens to be minter for the provided `amount` of Dollars to burn


```solidity
function getCreditReturnedForDollars(uint256 amount) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Amount of Dollars to burn|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of Credits to be minted|


### onERC1155Received

Handles the receipt of a single ERC1155 token type. This function is
called at the end of a `safeTransferFrom` after the balance has been updated.
NOTE: To accept the transfer, this must return
`bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
(i.e. 0xf23a6e61, or its own function selector).


```solidity
function onERC1155Received(address operator, address, uint256, uint256, bytes calldata)
    internal
    view
    returns (bytes4);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operator`|`address`|The address which initiated the transfer (i.e. msg.sender)|
|`<none>`|`address`||
|`<none>`|`uint256`||
|`<none>`|`uint256`||
|`<none>`|`bytes`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes4`|`bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed|


### burnExpiredCreditNftForGovernance

Burns expired Credit NFTs for Governance tokens at `expiredCreditNftConversionRate` rate


```solidity
function burnExpiredCreditNftForGovernance(uint256 id, uint256 amount) public returns (uint256 governanceAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`uint256`|Credit NFT timestamp|
|`amount`|`uint256`|Amount of Credit NFTs to burn|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`governanceAmount`|`uint256`|Amount of Governance tokens minted to Credit NFT holder|


### burnCreditNftForCredit

TODO: Should we leave it ?

Burns Credit NFTs for Credit tokens


```solidity
function burnCreditNftForCredit(uint256 id, uint256 amount) public returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`uint256`|Credit NFT timestamp|
|`amount`|`uint256`|Amount of Credit NFTs to burn|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Credit tokens balance of `msg.sender`|


### burnCreditTokensForDollars

Burns Credit tokens for Dollars when Dollar price > 1$


```solidity
function burnCreditTokensForDollars(uint256 amount) public returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Amount of Credits to burn|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of unredeemed Credits|


### redeemCreditNft

Burns Credit NFTs for Dollars when Dollar price > 1$


```solidity
function redeemCreditNft(uint256 id, uint256 amount) public returns (uint256);
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


### mintClaimableDollars

Mints Dollars when Dollar price > 1$

Distributes excess Dollars this way:
- 50% goes to the treasury address
- 10% goes for burning Dollar-Governance LP tokens in a DEX pool
- 40% goes to the Staking contract


```solidity
function mintClaimableDollars() public;
```

## Events
### ExpiredCreditNftConversionRateChanged
Emitted when Credit NFT to Governance conversion rate was updated


```solidity
event ExpiredCreditNftConversionRateChanged(uint256 newRate, uint256 previousRate);
```

### CreditNftLengthChanged
Emitted when Credit NFT block expiration length was updated


```solidity
event CreditNftLengthChanged(uint256 newCreditNftLengthBlocks, uint256 previousCreditNftLengthBlocks);
```

## Structs
### CreditNftManagerData
Struct used as a storage for the current library


```solidity
struct CreditNftManagerData {
    uint256 dollarsMintedThisCycle;
    uint256 blockHeightDebt;
    uint256 creditNftLengthBlocks;
    uint256 expiredCreditNftConversionRate;
    bool debtCycle;
}
```

