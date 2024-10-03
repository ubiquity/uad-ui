# LibCreditRedemptionCalculator
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/libraries/LibCreditRedemptionCalculator.sol)

Library for calculating amount of Credits to mint on Dollars burn


## State Variables
### CREDIT_REDEMPTION_CALCULATOR_STORAGE_SLOT
Storage slot used to store data for this library


```solidity
bytes32 constant CREDIT_REDEMPTION_CALCULATOR_STORAGE_SLOT =
    bytes32(uint256(keccak256("ubiquity.contracts.credit.redemption.calculator.storage")) - 1) & ~bytes32(uint256(0xff));
```


## Functions
### creditRedemptionCalculatorStorage

Returns struct used as a storage for this library


```solidity
function creditRedemptionCalculatorStorage() internal pure returns (CreditRedemptionCalculatorData storage l);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`l`|`CreditRedemptionCalculatorData`|Struct used as a storage|


### setConstant

Sets the `p` param in the Credit mint calculation formula:
`y = x * ((BlockDebtStart / BlockBurn) ^ p)`


```solidity
function setConstant(uint256 coef) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`coef`|`uint256`|New `p` param in wei|


### getConstant

Returns the `p` param used in the Credit mint calculation formula


```solidity
function getConstant() internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|`p` param|


### getCreditAmount

Returns amount of Credits to mint for `dollarsToBurn` amount of Dollars to burn


```solidity
function getCreditAmount(uint256 dollarsToBurn, uint256 blockHeightDebt) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`dollarsToBurn`|`uint256`|Amount of Dollars to burn|
|`blockHeightDebt`|`uint256`|Block number when the latest debt cycle started (i.e. when Dollar price became < 1$)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of Credits to mint|


## Structs
### CreditRedemptionCalculatorData
Struct used as a storage for the current library


```solidity
struct CreditRedemptionCalculatorData {
    uint256 coef;
}
```

