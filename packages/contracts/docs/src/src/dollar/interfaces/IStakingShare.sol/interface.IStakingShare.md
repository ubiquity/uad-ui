# IStakingShare
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/interfaces/IStakingShare.sol)

**Inherits:**
[IERC1155Ubiquity](/src/dollar/interfaces/IERC1155Ubiquity.sol/interface.IERC1155Ubiquity.md)

Interface representing a staking share in the form of ERC1155 token


## Functions
### getStake

Returns stake info by stake `id`


```solidity
function getStake(uint256 id) external view returns (Stake memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`uint256`|Stake id|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Stake`|Stake info|


## Structs
### Stake
Stake struct


```solidity
struct Stake {
    address minter;
    uint256 lpFirstDeposited;
    uint256 creationBlock;
    uint256 lpRewardDebt;
    uint256 endBlock;
    uint256 lpAmount;
}
```

