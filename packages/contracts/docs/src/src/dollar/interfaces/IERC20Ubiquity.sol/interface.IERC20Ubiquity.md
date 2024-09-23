# IERC20Ubiquity
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/interfaces/IERC20Ubiquity.sol)

**Inherits:**
IERC20, IERC20Permit

Interface for ERC20Ubiquity contract


## Functions
### burn

Burns tokens from `msg.sender`


```solidity
function burn(uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Amount of tokens to burn|


### burnFrom

Burns tokens from the `account` address


```solidity
function burnFrom(address account, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address to burn tokens from|
|`amount`|`uint256`|Amount of tokens to burn|


### mint

Mints tokens to the `account` address


```solidity
function mint(address account, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address to mint tokens to|
|`amount`|`uint256`|Amount of tokens to mint|


## Events
### Minting
Emitted on tokens minting


```solidity
event Minting(address indexed _to, address indexed _minter, uint256 _amount);
```

### Burning
Emitted on tokens burning


```solidity
event Burning(address indexed _burned, uint256 _amount);
```

