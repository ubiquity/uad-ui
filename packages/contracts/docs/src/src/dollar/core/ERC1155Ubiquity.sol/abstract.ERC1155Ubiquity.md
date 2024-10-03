# ERC1155Ubiquity
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/core/ERC1155Ubiquity.sol)

**Inherits:**
Initializable, ERC1155BurnableUpgradeable, ERC1155PausableUpgradeable, UUPSUpgradeable

ERC1155 Ubiquity preset

ERC1155 with:
- ERC1155 minter, burner and pauser
- TotalSupply per id
- Ubiquity Manager access control


## State Variables
### accessControl
Access control interface


```solidity
IAccessControl public accessControl;
```


### holderBalances
Mapping from account to array of token ids held by the account


```solidity
mapping(address => uint256[]) public holderBalances;
```


### totalSupply
Total supply among all token ids


```solidity
uint256 public totalSupply;
```


### __gap
Allows for future upgrades on the base contract without affecting the storage of the derived contract


```solidity
uint256[50] private __gap;
```


## Functions
### onlyMinter

Modifier checks that the method is called by a user with the "Governance minter" role


```solidity
modifier onlyMinter() virtual;
```

### onlyBurner

Modifier checks that the method is called by a user with the "Governance burner" role


```solidity
modifier onlyBurner() virtual;
```

### onlyPauser

Modifier checks that the method is called by a user with the "Pauser" role


```solidity
modifier onlyPauser() virtual;
```

### onlyAdmin

Modifier checks that the method is called by a user with the "Admin" role


```solidity
modifier onlyAdmin();
```

### constructor

Ensures __ERC1155Ubiquity_init cannot be called on the implementation contract


```solidity
constructor();
```

### __ERC1155Ubiquity_init

Initializes this contract with all base(parent) contracts


```solidity
function __ERC1155Ubiquity_init(address _manager, string memory _uri) internal onlyInitializing;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_manager`|`address`|Address of the manager of the contract|
|`_uri`|`string`|Base URI|


### __ERC1155Ubiquity_init_unchained

Initializes the current contract


```solidity
function __ERC1155Ubiquity_init_unchained(address _manager) internal onlyInitializing;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_manager`|`address`|Address of the manager of the contract|


### getManager

Returns access control address


```solidity
function getManager() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Access control address|


### setManager

Sets access control address


```solidity
function setManager(address _manager) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_manager`|`address`|New access control address|


### setUri

Sets base URI


```solidity
function setUri(string memory newURI) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newURI`|`string`|New URI|


### mint

Creates `amount` new tokens for `to`, of token type `id`


```solidity
function mint(address to, uint256 id, uint256 amount, bytes memory data) public virtual onlyMinter;
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
function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    public
    virtual
    onlyMinter
    whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address where to mint tokens|
|`ids`|`uint256[]`|Array of token type ids|
|`amounts`|`uint256[]`|Array of token amounts|
|`data`|`bytes`|Arbitrary data|


### pause

Pauses all token transfers


```solidity
function pause() public virtual onlyPauser;
```

### unpause

Unpauses all token transfers


```solidity
function unpause() public virtual onlyPauser;
```

### safeTransferFrom

Transfers `amount` tokens of token type `id` from `from` to `to`.
Emits a `TransferSingle` event.
Requirements:
- `to` cannot be the zero address.
- If the caller is not `from`, it must have been approved to spend ``from``'s tokens via `setApprovalForAll`.
- `from` must have a balance of tokens of type `id` of at least `amount`.
- If `to` refers to a smart contract, it must implement `IERC1155Receiver-onERC1155Received` and return the
acceptance magic value.


```solidity
function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data)
    public
    virtual
    override;
```

### safeBatchTransferFrom

Batched version of `safeTransferFrom()`
Emits a `TransferBatch` event.
Requirements:
- `ids` and `amounts` must have the same length.
- If `to` refers to a smart contract, it must implement `IERC1155Receiver-onERC1155BatchReceived` and return the
acceptance magic value.


```solidity
function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
) public virtual override;
```

### holderTokens

Returns array of token ids held by the `holder`


```solidity
function holderTokens(address holder) public view returns (uint256[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`holder`|`address`|Account to check tokens for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|Array of tokens which `holder` has|


### _burn

Destroys `amount` tokens of token type `id` from `account`
Emits a `TransferSingle` event.
Requirements:
- `account` cannot be the zero address.
- `account` must have at least `amount` tokens of token type `id`.


```solidity
function _burn(address account, uint256 id, uint256 amount) internal virtual override whenNotPaused;
```

### _burnBatch

Batched version of `_burn()`
Emits a `TransferBatch` event.
Requirements:
- `ids` and `amounts` must have the same length.


```solidity
function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts)
    internal
    virtual
    override
    whenNotPaused;
```

### _beforeTokenTransfer

Hook that is called before any token transfer. This includes minting
and burning, as well as batched variants.
The same hook is called on both single and batched variants. For single
transfers, the length of the `ids` and `amounts` arrays will be 1.
Calling conditions (for each `id` and `amount` pair):
- When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
of token type `id` will be  transferred to `to`.
- When `from` is zero, `amount` tokens of token type `id` will be minted
for `to`.
- when `to` is zero, `amount` of ``from``'s tokens of token type `id`
will be burned.
- `from` and `to` are never both zero.
- `ids` and `amounts` have the same, non-zero length.


```solidity
function _beforeTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
) internal virtual override(ERC1155PausableUpgradeable, ERC1155Upgradeable);
```

### _authorizeUpgrade

Allows an admin to upgrade to another implementation contract


```solidity
function _authorizeUpgrade(address newImplementation) internal virtual override onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newImplementation`|`address`|Address of the new implementation contract|


