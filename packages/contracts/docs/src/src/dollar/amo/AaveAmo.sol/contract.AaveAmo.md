# AaveAmo
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/amo/AaveAmo.sol)

**Inherits:**
[IAmo](/src/dollar/interfaces/IAmo.sol/interface.IAmo.md), Ownable

AMO to interact with Aave V3: supply and manage rewards.

Can receive collateral from UbiquityAmoMinter and interact with Aave's V3 pool.


## State Variables
### amoMinter
UbiquityAmoMinter instance


```solidity
UbiquityAmoMinter public amoMinter;
```


### aavePool
Aave V3 pool instance


```solidity
IPool public immutable aavePool;
```


### aaveRewardsController
Aave rewards controller


```solidity
IRewardsController public immutable aaveRewardsController;
```


## Functions
### constructor

Initializes the contract with necessary parameters


```solidity
constructor(address _ownerAddress, address _amoMinterAddress, address _aavePool, address _aaveRewardsController);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ownerAddress`|`address`|Address of the contract owner|
|`_amoMinterAddress`|`address`|Address of the Ubiquity Amo minter|
|`_aavePool`|`address`|Address of the Aave pool|
|`_aaveRewardsController`|`address`|Address of the Aave rewards controller|


### aaveDepositCollateral

Deposits collateral to Aave pool


```solidity
function aaveDepositCollateral(address collateralAddress, uint256 amount) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralAddress`|`address`|Address of the collateral ERC20|
|`amount`|`uint256`|Amount of collateral to deposit|


### aaveWithdrawCollateral

Withdraws collateral from Aave pool


```solidity
function aaveWithdrawCollateral(address collateralAddress, uint256 aTokenAmount) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralAddress`|`address`|Address of the collateral ERC20|
|`aTokenAmount`|`uint256`|Amount of collateral to withdraw|


### claimAllRewards

Claims all rewards available from the list of assets provided, will fail if balance on asset is zero


```solidity
function claimAllRewards(address[] memory assets) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`assets`|`address[]`|Array of aTokens/sTokens/vTokens addresses to claim rewards from|


### returnCollateralToMinter

Returns collateral back to the AMO minter


```solidity
function returnCollateralToMinter(uint256 collateralAmount) public override onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralAmount`|`uint256`|Amount of collateral to return, pass 0 to return all collateral|


### setAmoMinter

Sets the AMO minter address


```solidity
function setAmoMinter(address _amoMinterAddress) external override onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amoMinterAddress`|`address`|New address of the AMO minter|


### recoverERC20

Recovers any ERC20 tokens held by the contract


```solidity
function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenAddress`|`address`|Address of the token to recover|
|`tokenAmount`|`uint256`|Amount of tokens to recover|


### execute

Executes arbitrary calls from this contract


```solidity
function execute(address _to, uint256 _value, bytes calldata _data) external onlyOwner returns (bool, bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Address to call|
|`_value`|`uint256`|Value to send|
|`_data`|`bytes`|Data to execute|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success, result Returns whether the call succeeded and the returned data|
|`<none>`|`bytes`||


## Events
### CollateralDeposited

```solidity
event CollateralDeposited(address indexed collateralAddress, uint256 amount);
```

### CollateralWithdrawn

```solidity
event CollateralWithdrawn(address indexed collateralAddress, uint256 amount);
```

### CollateralReturnedToMinter

```solidity
event CollateralReturnedToMinter(uint256 amount);
```

### RewardsClaimed

```solidity
event RewardsClaimed();
```

### AmoMinterSet

```solidity
event AmoMinterSet(address indexed newMinter);
```

### ERC20Recovered

```solidity
event ERC20Recovered(address tokenAddress, uint256 tokenAmount);
```

### ExecuteCalled

```solidity
event ExecuteCalled(address indexed to, uint256 value, bytes data);
```

