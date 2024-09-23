# ICollectableDust
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/interfaces/utils/ICollectableDust.sol)

Interface for collecting dust (i.e. not part of a protocol) tokens sent to a contract


## Functions
### addProtocolToken

Adds token address to a protocol


```solidity
function addProtocolToken(address _token) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Token address to add|


### removeProtocolToken

Removes token address from a protocol


```solidity
function removeProtocolToken(address _token) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Token address to remove|


### sendDust

Sends dust tokens (which are not part of a protocol) to the `_to` address


```solidity
function sendDust(address _to, address _token, uint256 _amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Tokens receiver address|
|`_token`|`address`|Token address to send|
|`_amount`|`uint256`|Amount of tokens to send|


## Events
### DustSent
Emitted when dust tokens are sent to the `_to` address


```solidity
event DustSent(address _to, address token, uint256 amount);
```

### ProtocolTokenAdded
Emitted when token is added to a protocol


```solidity
event ProtocolTokenAdded(address _token);
```

### ProtocolTokenRemoved
Emitted when token is removed from a protocol


```solidity
event ProtocolTokenRemoved(address _token);
```

