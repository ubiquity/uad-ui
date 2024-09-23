# DiamondLoupeFacet
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/facets/DiamondLoupeFacet.sol)

**Inherits:**
[IDiamondLoupe](/src/dollar/interfaces/IDiamondLoupe.sol/interface.IDiamondLoupe.md), IERC165

A loupe is a small magnifying glass used to look at diamonds.
These functions look at diamonds.

*These functions are expected to be called frequently by 3rd party tools.*

*The functions in DiamondLoupeFacet MUST be added to a diamond.
The EIP-2535 Diamond standard requires these functions.*


## Functions
### facets

Returns all facet addresses and their four byte function selectors


```solidity
function facets() external view override returns (Facet[] memory facets_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`facets_`|`Facet[]`|Facets with function selectors|


### facetFunctionSelectors

Returns all function selectors supported by a specific facet


```solidity
function facetFunctionSelectors(address _facet)
    external
    view
    override
    returns (bytes4[] memory facetFunctionSelectors_);
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
function facetAddresses() external view override returns (address[] memory facetAddresses_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`facetAddresses_`|`address[]`|Facet addresses in a diamond|


### facetAddress

Returns the facet that supports the given selector

*If facet is not found returns `address(0)`*


```solidity
function facetAddress(bytes4 _functionSelector) external view override returns (address facetAddress_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_functionSelector`|`bytes4`|Function selector|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`facetAddress_`|`address`|Facet address|


### supportsInterface

Returns `true` if this contract implements the interface defined by
`interfaceId`. See the corresponding
https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
to learn more about how these ids are created.
This function call must use less than 30 000 gas.


```solidity
function supportsInterface(bytes4 _interfaceId) external view override returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Whether contract supports a provided interface|


