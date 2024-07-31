# IERC173
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/interfaces/IERC173.sol)

ERC-173 Contract Ownership Standard

*ERC-165 identifier for this interface is 0x7f5828d0*


## Functions
### owner

Returns owner's address


```solidity
function owner() external view returns (address owner_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`owner_`|`address`|Owner address|


### transferOwnership

Sets contract's owner to a new address

*Set _newOwner to address(0) to renounce any ownership*


```solidity
function transferOwnership(address _newOwner) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newOwner`|`address`|The address of the new owner of the contract|


## Events
### OwnershipTransferred
Emits when ownership of a contract changes


```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
```

