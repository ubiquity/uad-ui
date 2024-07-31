# LibAccessControl
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/libraries/LibAccessControl.sol)

Access control library


## State Variables
### ACCESS_CONTROL_STORAGE_SLOT
Storage slot used to store data for this library


```solidity
bytes32 constant ACCESS_CONTROL_STORAGE_SLOT =
    bytes32(uint256(keccak256("ubiquity.contracts.access.control.storage")) - 1) & ~bytes32(uint256(0xff));
```


## Functions
### accessControlStorage

Returns struct used as a storage for this library


```solidity
function accessControlStorage() internal pure returns (Layout storage l);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`l`|`Layout`|Struct used as a storage|


### onlyRole

Checks that a method can only be called by the provided role


```solidity
modifier onlyRole(bytes32 role);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role name|


### paused

Returns true if the contract is paused and false otherwise


```solidity
function paused() internal view returns (bool);
```

### hasRole

Checks whether role is assigned to account


```solidity
function hasRole(bytes32 role, address account) internal view returns (bool);
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


### checkRole

Reverts if sender does not have a given role


```solidity
function checkRole(bytes32 role) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to query|


### checkRole

Reverts if given account does not have a given role


```solidity
function checkRole(bytes32 role, address account) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to query|
|`account`|`address`|Address to query|


### getRoleAdmin

Returns admin role for a given role


```solidity
function getRoleAdmin(bytes32 role) internal view returns (bytes32);
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

Sets a new admin role for a provided role


```solidity
function setRoleAdmin(bytes32 role, bytes32 adminRole) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role for which admin role should be set|
|`adminRole`|`bytes32`|Admin role to set|


### grantRole

Assigns role to a given account


```solidity
function grantRole(bytes32 role, address account) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to assign|
|`account`|`address`|Recipient of role assignment|


### revokeRole

Unassign role from a given account


```solidity
function revokeRole(bytes32 role, address account) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to unassign|
|`account`|`address`|Address from which the provided role should be unassigned|


### renounceRole

Renounces role


```solidity
function renounceRole(bytes32 role) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to renounce|


### pause

Pauses the contract


```solidity
function pause() internal;
```

### unpause

Unpauses the contract


```solidity
function unpause() internal;
```

## Events
### RoleAdminChanged
Emitted when admin role of a role is updated


```solidity
event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
```

### RoleGranted
Emitted when role is granted to account


```solidity
event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
```

### RoleRevoked
Emitted when role is revoked from account


```solidity
event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
```

### Paused
Emitted when the pause is triggered by `account`


```solidity
event Paused(address account);
```

### Unpaused
Emitted when the pause is lifted by `account`


```solidity
event Unpaused(address account);
```

## Structs
### RoleData
Structure to keep all role members with their admin role


```solidity
struct RoleData {
    EnumerableSet.AddressSet members;
    bytes32 adminRole;
}
```

### Layout
Structure to keep all protocol roles


```solidity
struct Layout {
    mapping(bytes32 => RoleData) roles;
}
```

