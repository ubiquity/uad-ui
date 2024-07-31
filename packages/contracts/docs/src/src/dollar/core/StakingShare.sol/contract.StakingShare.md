# StakingShare
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/core/StakingShare.sol)

**Inherits:**
[ERC1155Ubiquity](/src/dollar/core/ERC1155Ubiquity.sol/abstract.ERC1155Ubiquity.md), ERC1155URIStorageUpgradeable

Contract representing a staking share in the form of ERC1155 token


## State Variables
### _stakes
Mapping of stake id to stake info


```solidity
mapping(uint256 => Stake) private _stakes;
```


### _totalLP
Total LP amount staked


```solidity
uint256 private _totalLP;
```


### _baseURI
Base token URI


```solidity
string private _baseURI;
```


## Functions
### onlyMinter

Modifier checks that the method is called by a user with the "Staking share minter" role


```solidity
modifier onlyMinter() override;
```

### onlyBurner

Modifier checks that the method is called by a user with the "Staking share burner" role


```solidity
modifier onlyBurner() override;
```

### onlyPauser

Modifier checks that the method is called by a user with the "Pauser" role


```solidity
modifier onlyPauser() override;
```

### constructor

Ensures initialize cannot be called on the implementation contract


```solidity
constructor();
```

### initialize

Initializes this contract


```solidity
function initialize(address _manager, string memory _uri) public virtual initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_manager`|`address`|Address of the manager of the contract|
|`_uri`|`string`|Base URI|


### updateStake

Updates a staking share


```solidity
function updateStake(uint256 _stakeId, uint256 _lpAmount, uint256 _lpRewardDebt, uint256 _endBlock)
    external
    onlyMinter
    whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stakeId`|`uint256`|Staking share id|
|`_lpAmount`|`uint256`|Amount of Dollar-3CRV LP tokens deposited|
|`_lpRewardDebt`|`uint256`|Amount of excess LP token inside the staking contract|
|`_endBlock`|`uint256`|Block number when the locking period ends|


### mint

Mints a single staking share token for the `to` address


```solidity
function mint(address to, uint256 lpDeposited, uint256 lpRewardDebt, uint256 endBlock)
    public
    virtual
    onlyMinter
    whenNotPaused
    returns (uint256 id);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Owner address|
|`lpDeposited`|`uint256`|Amount of Dollar-3CRV LP tokens deposited|
|`lpRewardDebt`|`uint256`|Amount of excess LP tokens inside the staking contract|
|`endBlock`|`uint256`|Block number when the locking period ends|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`id`|`uint256`|Minted staking share id|


### safeTransferFrom

Transfers `amount` tokens of token type `id` from `from` to `to`.
Emits a {TransferSingle} event.
Requirements:
- `to` cannot be the zero address.
- If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
- `from` must have a balance of tokens of type `id` of at least `amount`.
- If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
acceptance magic value.


```solidity
function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data)
    public
    override(ERC1155Upgradeable, ERC1155Ubiquity)
    whenNotPaused;
```

### totalLP

Returns total amount of Dollar-3CRV LP tokens deposited


```solidity
function totalLP() public view virtual returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Total amount of LP tokens deposited|


### getStake

Returns stake info


```solidity
function getStake(uint256 id) public view returns (Stake memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`uint256`|Staking share id|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Stake`|Staking share info|


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
) public virtual override(ERC1155Upgradeable, ERC1155Ubiquity) whenNotPaused;
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
    override(ERC1155Upgradeable, ERC1155Ubiquity)
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
) internal virtual override(ERC1155Upgradeable, ERC1155Ubiquity);
```

### uri

Returns URI by token id


```solidity
function uri(uint256 tokenId)
    public
    view
    virtual
    override(ERC1155Upgradeable, ERC1155URIStorageUpgradeable)
    returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|Token id|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|URI string|


### _burn

Destroys `amount` tokens of token type `id` from `account`
Emits a `TransferSingle` event.
Requirements:
- `account` cannot be the zero address.
- `account` must have at least `amount` tokens of token type `id`.


```solidity
function _burn(address account, uint256 id, uint256 amount)
    internal
    virtual
    override(ERC1155Upgradeable, ERC1155Ubiquity)
    whenNotPaused;
```

### setUri

Sets URI for token type `tokenId`


```solidity
function setUri(uint256 tokenId, string memory tokenUri) external onlyMinter;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|Token type id|
|`tokenUri`|`string`|Token URI|


### setBaseUri

Sets base URI for all token types


```solidity
function setBaseUri(string memory newUri) external onlyMinter;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newUri`|`string`|New URI string|


### getBaseUri

Returns base URI for all token types


```solidity
function getBaseUri() external view returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|Base URI string|


### _authorizeUpgrade

Allows an admin to upgrade to another implementation contract


```solidity
function _authorizeUpgrade(address newImplementation) internal override onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newImplementation`|`address`|Address of the new implementation contract|


## Structs
### Stake
Stake struct


```solidity
struct Stake {
    address minter;
    uint256 lpFirstDeposited;
    uint256 creationBlock;
    uint256 lpRewardDebt;
    uint256 endBlock;
    uint256 lpAmount;
}
```

