# IDiamondLoupe
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/interfaces/IDiamondLoupe.sol)

A loupe is a small magnifying glass used to look at diamonds.
These functions look at diamonds.

*These functions are expected to be called frequently by 3rd party tools.*


## Functions
### facets

Returns all facet addresses and their four byte function selectors


```solidity
function facets() external view returns (Facet[] memory facets_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`facets_`|`Facet[]`|Facets with function selectors|


### facetFunctionSelectors

Returns all function selectors supported by a specific facet


```solidity
function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_facet`|`address`|Facet address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`facetFunctionSelectors_`|`bytes4[]`|Function selectors for a particular facet|


### facetAddresses

Returns all facet addresses used by a diamond


```solidity
function facetAddresses() external view returns (address[] memory facetAddresses_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`facetAddresses_`|`address[]`|Facet addresses in a diamond|


### facetAddress

Returns the facet that supports the given selector

*If facet is not found returns `address(0)`*


```solidity
function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_functionSelector`|`bytes4`|Function selector|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`facetAddress_`|`address`|Facet address|


## Structs
### Facet
Struct used as a mapping of facet to function selectors


```solidity
struct Facet {
    address facetAddress;
    bytes4[] functionSelectors;
}
```

