# CollectableDustFacet
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/facets/CollectableDustFacet.sol)

**Inherits:**
[ICollectableDust](/src/dollar/interfaces/utils/ICollectableDust.sol/interface.ICollectableDust.md), [Modifiers](/src/dollar/libraries/LibAppStorage.sol/contract.Modifiers.md)

Contract for collecting dust (i.e. not part of a protocol) tokens sent to a contract


## Functions
### addProtocolToken

Adds token address to a protocol


```solidity
function addProtocolToken(address _token) external onlyStakingManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Token address to add|


### removeProtocolToken

Removes token address from a protocol


```solidity
function removeProtocolToken(address _token) external onlyStakingManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Token address to remove|


### sendDust

Sends dust tokens (which are not part of a protocol) to the `_to` address


```solidity
function sendDust(address _to, address _token, uint256 _amount) external onlyStakingManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Tokens receiver address|
|`_token`|`address`|Token address to send|
|`_amount`|`uint256`|Amount of tokens to send|


