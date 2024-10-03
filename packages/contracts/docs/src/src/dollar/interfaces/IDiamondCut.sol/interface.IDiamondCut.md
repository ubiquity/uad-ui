# IDiamondCut
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/interfaces/IDiamondCut.sol)

Interface that allows modifications to diamond function selector mapping


## Functions
### diamondCut

Add/replace/remove any number of functions and optionally execute a function with delegatecall

*`_calldata` is executed with delegatecall on `_init`*


```solidity
function diamondCut(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_diamondCut`|`FacetCut[]`|Contains the facet addresses and function selectors|
|`_init`|`address`|The address of the contract or facet to execute _calldata|
|`_calldata`|`bytes`|A function call, including function selector and arguments|


## Events
### DiamondCut
Emitted when facet selectors are modified


```solidity
event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
```

## Structs
### FacetCut
Struct used as a mapping of facet to function selectors


```solidity
struct FacetCut {
    address facetAddress;
    FacetCutAction action;
    bytes4[] functionSelectors;
}
```

## Enums
### FacetCutAction
Available diamond operations

*Add=0, Replace=1, Remove=2*


```solidity
enum FacetCutAction {
    Add,
    Replace,
    Remove
}
```

