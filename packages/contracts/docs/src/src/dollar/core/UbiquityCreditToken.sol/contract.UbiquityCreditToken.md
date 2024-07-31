# UbiquityCreditToken
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/core/UbiquityCreditToken.sol)

**Inherits:**
[ERC20Ubiquity](/src/dollar/core/ERC20Ubiquity.sol/abstract.ERC20Ubiquity.md)

Credit token contract


## Functions
### constructor

Ensures initialize cannot be called on the implementation contract


```solidity
constructor();
```

### initialize

Initializes the contract


```solidity
function initialize(address _manager) public initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_manager`|`address`|Address of the Ubiquity Manager|


### onlyCreditMinter

Modifier checks that the method is called by a user with the "Credit minter" role


```solidity
modifier onlyCreditMinter();
```

### onlyCreditBurner

Modifier checks that the method is called by a user with the "Credit burner" role


```solidity
modifier onlyCreditBurner();
```

### raiseCapital

Raises capital in the form of Ubiquity Credit Token

*CREDIT_TOKEN_MINTER_ROLE access control role is required to call this function*


```solidity
function raiseCapital(uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Amount to be minted|


### burnFrom

Burns Ubiquity Credit tokens from specified account


```solidity
function burnFrom(address account, uint256 amount) public override onlyCreditBurner whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Account to burn from|
|`amount`|`uint256`|Amount to burn|


### mint

Creates `amount` new Credit tokens for `to`


```solidity
function mint(address to, uint256 amount) public onlyCreditMinter whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Account to mint Credit tokens to|
|`amount`|`uint256`|Amount of Credit tokens to mint|


### _authorizeUpgrade

Allows an admin to upgrade to another implementation contract


```solidity
function _authorizeUpgrade(address newImplementation) internal override onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newImplementation`|`address`|Address of the new implementation contract|


