# LibDiamond
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/libraries/LibDiamond.sol)

Library used for diamond facets and selector modifications

*Remember to add the loupe functions from DiamondLoupeFacet to the diamond.
The loupe functions are required by the EIP2535 Diamonds standard.*


## State Variables
### DIAMOND_STORAGE_POSITION
Storage slot used to store data for this library


```solidity
bytes32 constant DIAMOND_STORAGE_POSITION =
    bytes32(uint256(keccak256("diamond.standard.diamond.storage")) - 1) & ~bytes32(uint256(0xff));
```


## Functions
### diamondStorage

Returns struct used as a storage for this library


```solidity
function diamondStorage() internal pure returns (DiamondStorage storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`DiamondStorage`|Struct used as a storage|


### setContractOwner

Updates contract owner


```solidity
function setContractOwner(address _newOwner) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newOwner`|`address`|New contract owner|


### contractOwner

Returns contract owner


```solidity
function contractOwner() internal view returns (address contractOwner_);
```

### enforceIsContractOwner

Checks that `msg.sender` is a contract owner


```solidity
function enforceIsContractOwner() internal view;
```

### diamondCut

Add/replace/remove any number of functions and optionally execute a function with delegatecall

*`_calldata` is executed with delegatecall on `_init`*


```solidity
function diamondCut(IDiamondCut.FacetCut[] memory _diamondCut, address _init, bytes memory _calldata) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_diamondCut`|`IDiamondCut.FacetCut[]`|Contains the facet addresses and function selectors|
|`_init`|`address`|The address of the contract or facet to execute _calldata|
|`_calldata`|`bytes`|A function call, including function selector and arguments|


### addFunctions

Adds new functions to a facet


```solidity
function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_facetAddress`|`address`|Facet address|
|`_functionSelectors`|`bytes4[]`|Function selectors to add|


### replaceFunctions

Replaces functions in a facet


```solidity
function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_facetAddress`|`address`|Facet address|
|`_functionSelectors`|`bytes4[]`|Function selectors to replace with|


### removeFunctions

Removes functions from a facet


```solidity
function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_facetAddress`|`address`|Facet address|
|`_functionSelectors`|`bytes4[]`|Function selectors to remove|


### addFacet

Adds a new diamond facet


```solidity
function addFacet(DiamondStorage storage ds, address _facetAddress) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`DiamondStorage`|Struct used as a storage|
|`_facetAddress`|`address`|Facet address to add|


### addFunction

Adds new function to a facet


```solidity
function addFunction(DiamondStorage storage ds, bytes4 _selector, uint96 _selectorPosition, address _facetAddress)
    internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`DiamondStorage`|Struct used as a storage|
|`_selector`|`bytes4`|Function selector to add|
|`_selectorPosition`|`uint96`|Position in `FacetFunctionSelectors.functionSelectors` array|
|`_facetAddress`|`address`|Facet address|


### removeFunction

Removes function from a facet


```solidity
function removeFunction(DiamondStorage storage ds, address _facetAddress, bytes4 _selector) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`DiamondStorage`|Struct used as a storage|
|`_facetAddress`|`address`|Facet address|
|`_selector`|`bytes4`|Function selector to add|


### initializeDiamondCut

Function called on diamond cut modification

*`_calldata` is executed with delegatecall on `_init`*


```solidity
function initializeDiamondCut(address _init, bytes memory _calldata) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_init`|`address`|The address of the contract or facet to execute _calldata|
|`_calldata`|`bytes`|A function call, including function selector and arguments|


### enforceHasContractCode

Reverts if `_contract` address doesn't have any code


```solidity
function enforceHasContractCode(address _contract, string memory _errorMessage) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contract`|`address`|Contract address to check for empty code|
|`_errorMessage`|`string`|Error message|


## Events
### OwnershipTransferred
Emitted when contract owner is updated


```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
```

### DiamondCut
Emitted when facet is modified


```solidity
event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);
```

## Structs
### FacetAddressAndPosition
Struct used as a mapping of facet to function selector position


```solidity
struct FacetAddressAndPosition {
    address facetAddress;
    uint96 functionSelectorPosition;
}
```

### FacetFunctionSelectors
Struct used as a mapping of facet to function selectors


```solidity
struct FacetFunctionSelectors {
    bytes4[] functionSelectors;
    uint256 facetAddressPosition;
}
```

### DiamondStorage
Struct used as a storage for this library


```solidity
struct DiamondStorage {
    mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
    mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
    address[] facetAddresses;
    mapping(bytes4 => bool) supportedInterfaces;
    address contractOwner;
}
```

