# DiamondInit
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/upgradeInitializers/DiamondInit.sol)

**Inherits:**
[Modifiers](/src/dollar/libraries/LibAppStorage.sol/contract.Modifiers.md)

It is expected that this contract is customized if you want to deploy your diamond
with data from a deployment script. Use the init function to initialize state variables
of your diamond. Add parameters to the init function if you need to.

How it works:
1. New `Diamond` contract is created
2. Inside the diamond's constructor there a `delegatecall()` to `DiamondInit` with the provided args
3. `DiamondInit` updates diamond storage


## Functions
### init

Initializes a diamond with state variables

*You can add parameters to this function in order to pass in data to set your own state variables*


```solidity
function init(Args memory _args) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_args`|`Args`|Init args|


## Structs
### Args
Struct used for diamond initialization


```solidity
struct Args {
    address admin;
    address[] tos;
    uint256[] amounts;
    uint256[] stakingShareIDs;
    uint256 governancePerBlock;
    uint256 creditNftLengthBlocks;
}
```

