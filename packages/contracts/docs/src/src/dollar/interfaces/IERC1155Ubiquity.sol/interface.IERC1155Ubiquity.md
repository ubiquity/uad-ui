# IERC1155Ubiquity
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/interfaces/IERC1155Ubiquity.sol)

**Inherits:**
IERC1155

ERC1155 Ubiquity interface

ERC1155 with:
- ERC1155 minter, burner and pauser
- TotalSupply per id
- Ubiquity Manager access control


## Functions
### mint

Creates `amount` new tokens for `to`, of token type `id`


```solidity
function mint(address to, uint256 id, uint256 amount, bytes memory data) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address where to mint tokens|
|`id`|`uint256`|Token type id|
|`amount`|`uint256`|Tokens amount to mint|
|`data`|`bytes`|Arbitrary data|


### mintBatch

Mints multiple token types for `to` address


```solidity
function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address where to mint tokens|
|`ids`|`uint256[]`|Array of token type ids|
|`amounts`|`uint256[]`|Array of token amounts|
|`data`|`bytes`|Arbitrary data|


### burn

Destroys `amount` tokens of token type `id` from `account`
Emits a `TransferSingle` event.
Requirements:
- `account` cannot be the zero address.
- `account` must have at least `amount` tokens of token type `id`.


```solidity
function burn(address account, uint256 id, uint256 value) external;
```

### burnBatch

Batched version of `_burn()`
Emits a `TransferBatch` event.
Requirements:
- `ids` and `amounts` must have the same length.


```solidity
function burnBatch(address account, uint256[] memory ids, uint256[] memory values) external;
```

### pause

Pauses all token transfers


```solidity
function pause() external;
```

### unpause

Unpauses all token transfers


```solidity
function unpause() external;
```

### totalSupply

Returns total supply among all token ids


```solidity
function totalSupply() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Total supply among all token ids|


### exists

Checks whether token `id` exists


```solidity
function exists(uint256 id) external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Whether token `id` exists|


### holderTokens

Returns array of token ids held by the `holder`


```solidity
function holderTokens(address holder) external view returns (uint256[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`holder`|`address`|Account to check tokens for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|Array of tokens which `holder` has|


