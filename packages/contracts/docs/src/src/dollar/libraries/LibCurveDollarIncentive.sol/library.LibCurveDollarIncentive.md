# LibCurveDollarIncentive
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/libraries/LibCurveDollarIncentive.sol)

Library adds buy incentive and sell penalty for Curve's Dollar-3CRV MetaPool


## State Variables
### CURVE_DOLLAR_STORAGE_SLOT
Storage slot used to store data for this library


```solidity
bytes32 constant CURVE_DOLLAR_STORAGE_SLOT =
    bytes32(uint256(keccak256("ubiquity.contracts.curve.storage")) - 1) & ~bytes32(uint256(0xff));
```


### _one
One point in `bytes16`


```solidity
bytes16 constant _one = bytes16(abi.encodePacked(uint256(1 ether)));
```


## Functions
### curveDollarStorage

Returns struct used as a storage for this library


```solidity
function curveDollarStorage() internal pure returns (CurveDollarData storage l);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`l`|`CurveDollarData`|Struct used as a storage|


### isSellPenaltyOn

Checks whether sell penalty is enabled


```solidity
function isSellPenaltyOn() internal view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Whether sell penalty is enabled|


### isBuyIncentiveOn

Checks whether buy incentive is enabled


```solidity
function isBuyIncentiveOn() internal view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Whether buy incentive is enabled|


### incentivize

Adds buy and sell incentives


```solidity
function incentivize(address sender, address receiver, uint256 amountIn) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|Sender address|
|`receiver`|`address`|Receiver address|
|`amountIn`|`uint256`|Trade amount|


### setExemptAddress

Sets an address to be exempted from Curve trading incentives


```solidity
function setExemptAddress(address account, bool isExempt) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address to update|
|`isExempt`|`bool`|Flag for whether to flag as exempt or not|


### switchSellPenalty

Switches the sell penalty


```solidity
function switchSellPenalty() internal;
```

### switchBuyIncentive

Switches the buy incentive


```solidity
function switchBuyIncentive() internal;
```

### isExemptAddress

Checks whether `account` is marked as exempt

Whether `account` is exempt from buy incentive and sell penalty


```solidity
function isExemptAddress(address account) internal view returns (bool);
```

### _incentivizeSell

Adds penalty for selling `amount` of Dollars for `target` address


```solidity
function _incentivizeSell(address target, uint256 amount) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|Address to penalize|
|`amount`|`uint256`|Trade amount|


### _incentivizeBuy

Adds incentive for buying `amountIn` of Dollars for `target` address


```solidity
function _incentivizeBuy(address target, uint256 amountIn) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|Address to incentivize|
|`amountIn`|`uint256`|Trade amount|


### _getPercentDeviationFromUnderPeg

Returns the percentage of deviation from the peg multiplied by amount when Dollar < 1$


```solidity
function _getPercentDeviationFromUnderPeg(uint256 amount) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Trade amount|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Percentage of deviation|


### _getTWAPPrice

Returns current Dollar price

*Returns 3CRV LP / Dollar quote, i.e. how many 3CRV LP tokens user will get for 1 Dollar*


```solidity
function _getTWAPPrice() internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Dollar price|


## Events
### ExemptAddressUpdate
Emitted when `_account` exempt is updated


```solidity
event ExemptAddressUpdate(address indexed _account, bool _isExempt);
```

## Structs
### CurveDollarData
Struct used as a storage for the current library


```solidity
struct CurveDollarData {
    bool isSellPenaltyOn;
    bool isBuyIncentiveOn;
    mapping(address => bool) _exempt;
}
```

