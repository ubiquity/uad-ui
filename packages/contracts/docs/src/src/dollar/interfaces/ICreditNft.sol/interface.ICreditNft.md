# ICreditNft
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/interfaces/ICreditNft.sol)

**Inherits:**
IERC1155Upgradeable

CreditNft interface


## Functions
### updateTotalDebt

Updates debt according to current block number

Invalidates expired CreditNfts

*Should be called prior to any state changing functions*


```solidity
function updateTotalDebt() external;
```

### burnCreditNft

Burns an `amount` of CreditNfts expiring at `expiryBlockNumber` from `creditNftOwner` balance


```solidity
function burnCreditNft(address creditNftOwner, uint256 amount, uint256 expiryBlockNumber) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`creditNftOwner`|`address`|Owner of those CreditNfts|
|`amount`|`uint256`|Amount of tokens to burn|
|`expiryBlockNumber`|`uint256`|Expiration block number of the CreditNfts to burn|


### mintCreditNft

Mint an `amount` of CreditNfts expiring at `expiryBlockNumber` for a certain `recipient`


```solidity
function mintCreditNft(address recipient, uint256 amount, uint256 expiryBlockNumber) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address`|Address where to mint tokens|
|`amount`|`uint256`|Amount of tokens to mint|
|`expiryBlockNumber`|`uint256`|Expiration block number of the CreditNfts to mint|


### getTotalOutstandingDebt

Returns outstanding debt by fetching current tally and removing any expired debt


```solidity
function getTotalOutstandingDebt() external view returns (uint256);
```

