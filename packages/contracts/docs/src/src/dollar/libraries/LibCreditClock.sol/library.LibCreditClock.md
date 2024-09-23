# LibCreditClock
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/libraries/LibCreditClock.sol)

Library for Credit Clock Facet


## State Variables
### CREDIT_CLOCK_STORAGE_POSITION
Storage slot used to store data for this library


```solidity
bytes32 constant CREDIT_CLOCK_STORAGE_POSITION =
    bytes32(uint256(keccak256("ubiquity.contracts.credit.clock.storage")) - 1) & ~bytes32(uint256(0xff));
```


## Functions
### creditClockStorage

Returns struct used as a storage for this library


```solidity
function creditClockStorage() internal pure returns (CreditClockData storage data);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`data`|`CreditClockData`|Struct used as a storage|


### setManager

Updates the manager address


```solidity
function setManager(address _manager) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_manager`|`address`|New manager address|


### getManager

Returns the manager address


```solidity
function getManager() internal view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Manager address|


### setRatePerBlock

Sets rate to apply from this block onward


```solidity
function setRatePerBlock(bytes16 _ratePerBlock) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ratePerBlock`|`bytes16`|ABDKMathQuad new rate per block to apply from this block onward|


### getRate

Calculates `rateStartValue * (1 / ((1 + ratePerBlock)^blockNumber - rateStartBlock)))`


```solidity
function getRate(uint256 blockNumber) internal view returns (bytes16 rate);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`blockNumber`|`uint256`|Block number to get the rate for. 0 for current block.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`rate`|`bytes16`|ABDKMathQuad rate calculated for the block number|


## Events
### SetRatePerBlock
Emitted when depreciation rate per block is updated


```solidity
event SetRatePerBlock(uint256 rateStartBlock, bytes16 rateStartValue, bytes16 ratePerBlock);
```

## Structs
### CreditClockData
Struct used as a storage for the current library


```solidity
struct CreditClockData {
    IAccessControl accessControl;
    uint256 rateStartBlock;
    bytes16 rateStartValue;
    bytes16 ratePerBlock;
    bytes16 one;
}
```

