# UbiquityGovernanceToken
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/core/UbiquityGovernanceToken.sol)

**Inherits:**
[ERC20Ubiquity](/src/dollar/core/ERC20Ubiquity.sol/abstract.ERC20Ubiquity.md)

Ubiquity Governance token contract


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


### onlyGovernanceMinter

Modifier checks that the method is called by a user with the "Governance minter" role


```solidity
modifier onlyGovernanceMinter();
```

### onlyGovernanceBurner

Modifier checks that the method is called by a user with the "Governance burner" role


```solidity
modifier onlyGovernanceBurner();
```

### burnFrom

Burns Governance tokens from the `account` address


```solidity
function burnFrom(address account, uint256 amount) public override onlyGovernanceBurner whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address to burn tokens from|
|`amount`|`uint256`|Amount of tokens to burn|


### mint

Mints Governance tokens to the `to` address


```solidity
function mint(address to, uint256 amount) public onlyGovernanceMinter whenNotPaused;
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


