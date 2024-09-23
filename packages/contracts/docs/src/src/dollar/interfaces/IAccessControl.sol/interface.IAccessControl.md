# IAccessControl
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/interfaces/IAccessControl.sol)

Access contol interface


## Functions
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


### setRoleAdmin

Sets admin role for a given role


```solidity
function setRoleAdmin(bytes32 role, bytes32 adminRole) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to set|
|`adminRole`|`bytes32`|Admin role to set for a provided role|


### grantRole

Assigns role to a given account


```solidity
function grantRole(bytes32 role, address account) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to assign|
|`account`|`address`|Recipient address of role assignment|


### revokeRole

Unassign role from a given account


```solidity
function revokeRole(bytes32 role, address account) external;
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


