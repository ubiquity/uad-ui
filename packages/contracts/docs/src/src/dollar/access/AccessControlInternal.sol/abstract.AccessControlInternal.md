# AccessControlInternal
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/access/AccessControlInternal.sol)

Role-based access control system

*Derived from https://github.com/OpenZeppelin/openzeppelin-contracts (MIT license)*

*https://github.com/solidstate-network/solidstate-solidity/blob/master/contracts/access/access_control/AccessControlInternal.sol*


## Functions
### onlyRole

Checks that a method can only be called by the provided role


```solidity
modifier onlyRole(bytes32 role);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role name|


### _hasRole

Checks whether role is assigned to account


```solidity
function _hasRole(bytes32 role, address account) internal view virtual returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to check|
|`account`|`address`|Account address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Whether role is assigned to account|


### _checkRole

Reverts if sender does not have a given role


```solidity
function _checkRole(bytes32 role) internal view virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to query|


### _checkRole

Reverts if given account does not have a given role


```solidity
function _checkRole(bytes32 role, address account) internal view virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to query|
|`account`|`address`|Address to query|


### _getRoleAdmin

Returns admin role for a given role


```solidity
function _getRoleAdmin(bytes32 role) internal view virtual returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to query|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|Admin role for the provided role|


### _setRoleAdmin

Set admin role for a given role


```solidity
function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to set|
|`adminRole`|`bytes32`|role for the provided role|


### _grantRole

Assigns role to a given account


```solidity
function _grantRole(bytes32 role, address account) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to assign|
|`account`|`address`|Recipient of role assignment|


### _revokeRole

Unassigns role from given account


```solidity
function _revokeRole(bytes32 role, address account) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to unassign|
|`account`|`address`|Account to revoke a role from|


### _renounceRole

Renounces role


```solidity
function _renounceRole(bytes32 role) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to renounce|


