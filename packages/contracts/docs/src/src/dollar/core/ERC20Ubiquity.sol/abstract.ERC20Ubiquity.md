# ERC20Ubiquity
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/core/ERC20Ubiquity.sol)

**Inherits:**
Initializable, UUPSUpgradeable, ERC20Upgradeable, ERC20PermitUpgradeable, ERC20PausableUpgradeable

Base contract for Ubiquity ERC20 tokens (Dollar, Credit, Governance)

ERC20 with:
- ERC20 minter, burner and pauser
- draft-ERC20 permit
- Ubiquity Manager access control


## State Variables
### _symbol
Token symbol


```solidity
string private _symbol;
```


### accessControl
Access control interface


```solidity
IAccessControl public accessControl;
```


### __gap
Allows for future upgrades on the base contract without affecting the storage of the derived contract


```solidity
uint256[50] private __gap;
```


## Functions
### onlyPauser

Modifier checks that the method is called by a user with the "pauser" role


```solidity
modifier onlyPauser();
```

### onlyAdmin

Modifier checks that the method is called by a user with the "admin" role


```solidity
modifier onlyAdmin();
```

### constructor

Ensures __ERC20Ubiquity_init cannot be called on the implementation contract


```solidity
constructor();
```

### __ERC20Ubiquity_init

Initializes this contract with all base(parent) contracts


```solidity
function __ERC20Ubiquity_init(address _manager, string memory name_, string memory symbol_) internal onlyInitializing;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_manager`|`address`|Address of the manager of the contract|
|`name_`|`string`|Token name|
|`symbol_`|`string`|Token symbol|


### __ERC20Ubiquity_init_unchained

Initializes the current contract


```solidity
function __ERC20Ubiquity_init_unchained(address _manager, string memory symbol_) internal onlyInitializing;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_manager`|`address`|Address of the manager of the contract|
|`symbol_`|`string`|Token symbol|


### setSymbol

Updates token symbol


```solidity
function setSymbol(string memory newSymbol) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newSymbol`|`string`|New token symbol name|


### symbol

Returns token symbol name


```solidity
function symbol() public view virtual override returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|Token symbol name|


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


### pause

Pauses all token transfers


```solidity
function pause() public onlyPauser;
```

### unpause

Unpauses all token transfers


```solidity
function unpause() public onlyPauser;
```

### burn

Destroys `amount` tokens from the caller


```solidity
function burn(uint256 amount) public virtual whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Amount of tokens to destroy|


### burnFrom

Destroys `amount` tokens from `account`, deducting from the caller's
allowance

Requirements:
- the caller must have allowance for `account`'s tokens of at least `amount`


```solidity
function burnFrom(address account, uint256 amount) public virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address to burn tokens from|
|`amount`|`uint256`|Amount of tokens to burn|


### _beforeTokenTransfer

Hook that is called before any transfer of tokens. This includes
minting and burning.
Calling conditions:
- when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
will be transferred to `to`.
- when `from` is zero, `amount` tokens will be minted for `to`.
- when `to` is zero, `amount` of ``from``'s tokens will be burned.
- `from` and `to` are never both zero.


```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount)
    internal
    virtual
    override(ERC20Upgradeable, ERC20PausableUpgradeable);
```

### _transfer

Moves `amount` of tokens from `from` to `to`.
This internal function is equivalent to `transfer`, and can be used to
e.g. implement automatic token fees, slashing mechanisms, etc.
Emits a `Transfer` event.
Requirements:
- `from` cannot be the zero address.
- `to` cannot be the zero address.
- `from` must have a balance of at least `amount`.


```solidity
function _transfer(address sender, address recipient, uint256 amount) internal virtual override whenNotPaused;
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


## Events
### Burning
Emitted when tokens are burned


```solidity
event Burning(address indexed _burned, uint256 _amount);
```

### Minting
Emitted when tokens are minted


```solidity
event Minting(address indexed _to, address indexed _minter, uint256 _amount);
```

