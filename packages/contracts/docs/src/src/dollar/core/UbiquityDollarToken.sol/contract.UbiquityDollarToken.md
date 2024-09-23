# UbiquityDollarToken
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/core/UbiquityDollarToken.sol)

**Inherits:**
[ERC20Ubiquity](/src/dollar/core/ERC20Ubiquity.sol/abstract.ERC20Ubiquity.md)

Ubiquity Dollar token contract


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


### onlyDollarMinter

Modifier checks that the method is called by a user with the "Dollar minter" role


```solidity
modifier onlyDollarMinter();
```

### onlyDollarBurner

Modifier checks that the method is called by a user with the "Dollar burner" role


```solidity
modifier onlyDollarBurner();
```

### burnFrom

Burns Dollars from the `account` address


```solidity
function burnFrom(address account, uint256 amount) public override onlyDollarBurner whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address to burn tokens from|
|`amount`|`uint256`|Amount of tokens to burn|


### mint

Mints Dollars to the `to` address


```solidity
function mint(address to, uint256 amount) public onlyDollarMinter whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address to mint tokens to|
|`amount`|`uint256`|Amount of tokens to mint|


### _authorizeUpgrade

Allows an admin to upgrade to another implementation contract


```solidity
function _authorizeUpgrade(address newImplementation) internal override onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newImplementation`|`address`|Address of the new implementation contract|


