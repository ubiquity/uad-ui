# AddressUtils
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/libraries/AddressUtils.sol)

Address utils

*https://github.com/solidstate-network/solidstate-solidity/blob/master/contracts/utils/AddressUtils.sol*


## Functions
### toString

Converts address to string


```solidity
function toString(address account) internal pure returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address to convert|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|String representation of `account`|


### isContract

Checks whether `account` has code

*NOTICE: NOT SAFE, can be circumvented in the `constructor()`*


```solidity
function isContract(address account) internal view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Whether `account` has code|


### sendValue

Sends ETH to `account`


```solidity
function sendValue(address payable account, uint256 amount) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address payable`|Address where to send ETH|
|`amount`|`uint256`|Amount of ETH to send|


### functionCall

Calls `target` with `data`


```solidity
function functionCall(address target, bytes memory data) internal returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|Target address|
|`data`|`bytes`|Data to pass|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`|Response bytes|


### functionCall

Calls `target` with `data`


```solidity
function functionCall(address target, bytes memory data, string memory error) internal returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|Target address|
|`data`|`bytes`|Data to pass|
|`error`|`string`|Text error|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`|Response bytes|


### functionCallWithValue

Calls `target` with `data`


```solidity
function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|Target address|
|`data`|`bytes`|Data to pass|
|`value`|`uint256`|Amount of ETH to send|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`|Response bytes|


### functionCallWithValue

Calls `target` with `data`


```solidity
function functionCallWithValue(address target, bytes memory data, uint256 value, string memory error)
    internal
    returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|Target address|
|`data`|`bytes`|Data to pass|
|`value`|`uint256`|Amount of ETH to send|
|`error`|`string`|Text error|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`|Response bytes|


### _functionCallWithValue

Calls `target` with `data`


```solidity
function _functionCallWithValue(address target, bytes memory data, uint256 value, string memory error)
    private
    returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|Target address|
|`data`|`bytes`|Data to pass|
|`value`|`uint256`|Amount of ETH to send|
|`error`|`string`|Text error|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`|Response bytes|


## Errors
### AddressUtils__InsufficientBalance
Thrown on insufficient balance


```solidity
error AddressUtils__InsufficientBalance();
```

### AddressUtils__NotContract
Thrown when target address has no code


```solidity
error AddressUtils__NotContract();
```

### AddressUtils__SendValueFailed
Thrown when sending ETH failed


```solidity
error AddressUtils__SendValueFailed();
```

