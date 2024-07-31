# AccessControlFacet
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/facets/AccessControlFacet.sol)

**Inherits:**
[Modifiers](/src/dollar/libraries/LibAppStorage.sol/contract.Modifiers.md), [IAccessControl](/src/dollar/interfaces/IAccessControl.sol/interface.IAccessControl.md), [AccessControlInternal](/src/dollar/access/AccessControlInternal.sol/abstract.AccessControlInternal.md)

Role-based access control facet

*Derived from https://github.com/OpenZeppelin/openzeppelin-contracts (MIT license)*

*https://github.com/solidstate-network/solidstate-solidity/blob/master/contracts/access/access_control/AccessControl.sol*


## Functions
### grantRole

Assigns role to a given account


```solidity
function grantRole(bytes32 role, address account) external onlyRole(_getRoleAdmin(role));
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to assign|
|`account`|`address`|Recipient address of role assignment|


### setRoleAdmin

Sets admin role for a given role


```solidity
function setRoleAdmin(bytes32 role, bytes32 adminRole) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to set|
|`adminRole`|`bytes32`|Admin role to set for a provided role|


### hasRole

Checks whether role is assigned to account


```solidity
function hasRole(bytes32 role, address account) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to check|
|`account`|`address`|Address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Whether role is assigned to account|


### getRoleAdmin

Returns admin role for a given role


```solidity
function getRoleAdmin(bytes32 role) external view returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to query|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|Admin role for a provided role|


### revokeRole

Unassign role from a given account


```solidity
function revokeRole(bytes32 role, address account) external onlyRole(_getRoleAdmin(role));
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to unassign|
|`account`|`address`|Address from which the provided role should be unassigned|


### renounceRole

Renounce role


```solidity
function renounceRole(bytes32 role) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to renounce|


### paused

Returns true if the contract is paused and false otherwise


```solidity
function paused() public view returns (bool);
```

### pause

Pauses the contract


```solidity
function pause() external whenNotPaused onlyAdmin;
```

### unpause

Unpauses the contract


```solidity
function unpause() external whenPaused onlyAdmin;
```

