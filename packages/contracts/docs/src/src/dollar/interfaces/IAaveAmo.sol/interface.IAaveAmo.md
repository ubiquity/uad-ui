# IAaveAmo
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/interfaces/IAaveAmo.sol)


## Functions
### aaveDepositCollateral

Deposits collateral into the Aave pool


```solidity
function aaveDepositCollateral(address collateralAddress, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralAddress`|`address`|Address of the collateral ERC20 token|
|`amount`|`uint256`|Amount of collateral to deposit|


### aaveWithdrawCollateral

Withdraws collateral from the Aave pool


```solidity
function aaveWithdrawCollateral(address collateralAddress, uint256 aTokenAmount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralAddress`|`address`|Address of the collateral ERC20 token|
|`aTokenAmount`|`uint256`|Amount of aTokens (collateral) to withdraw|


### aaveBorrow

Borrows an asset from the Aave pool


```solidity
function aaveBorrow(address asset, uint256 borrowAmount, uint256 interestRateMode) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`asset`|`address`|Address of the asset to borrow|
|`borrowAmount`|`uint256`|Amount of the asset to borrow|
|`interestRateMode`|`uint256`|Interest rate mode: 1 for stable, 2 for variable|


### aaveRepay

Repays a borrowed asset to the Aave pool


```solidity
function aaveRepay(address asset, uint256 repayAmount, uint256 interestRateMode) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`asset`|`address`|Address of the asset to repay|
|`repayAmount`|`uint256`|Amount of the asset to repay|
|`interestRateMode`|`uint256`|Interest rate mode: 1 for stable, 2 for variable|


### claimAllRewards

Claims all rewards from the provided assets


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
function returnCollateralToMinter(uint256 collateralAmount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralAmount`|`uint256`|Amount of collateral to return|


### setAmoMinter

Sets the address of the AMO minter


```solidity
function setAmoMinter(address _amoMinterAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amoMinterAddress`|`address`|New address of the AMO minter|


### recoverERC20

Recovers any ERC20 tokens held by the contract


```solidity
function recoverERC20(address tokenAddress, uint256 tokenAmount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenAddress`|`address`|Address of the token to recover|
|`tokenAmount`|`uint256`|Amount of tokens to recover|


### execute

Executes an arbitrary call from the contract


```solidity
function execute(address _to, uint256 _value, bytes calldata _data) external returns (bool, bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Address to call|
|`_value`|`uint256`|Value to send with the call|
|`_data`|`bytes`|Data to execute in the call|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success Boolean indicating whether the call succeeded|
|`<none>`|`bytes`|result Bytes data returned from the call|


## Events
### CollateralDeposited
Emitted when collateral is deposited into the Aave pool


```solidity
event CollateralDeposited(address indexed collateralAddress, uint256 amount);
```

### CollateralWithdrawn
Emitted when collateral is withdrawn from the Aave pool


```solidity
event CollateralWithdrawn(address indexed collateralAddress, uint256 amount);
```

### Borrowed
Emitted when an asset is borrowed from the Aave pool


```solidity
event Borrowed(address indexed asset, uint256 amount, uint256 interestRateMode);
```

### Repaid
Emitted when a borrowed asset is repaid to the Aave pool


```solidity
event Repaid(address indexed asset, uint256 amount, uint256 interestRateMode);
```

### CollateralReturnedToMinter
Emitted when collateral is returned to the AMO minter


```solidity
event CollateralReturnedToMinter(uint256 amount);
```

### RewardsClaimed
Emitted when rewards are claimed


```solidity
event RewardsClaimed();
```

### AmoMinterSet
Emitted when the AMO minter address is set


```solidity
event AmoMinterSet(address indexed newMinter);
```

### ERC20Recovered
Emitted when ERC20 tokens are recovered from the contract


```solidity
event ERC20Recovered(address tokenAddress, uint256 tokenAmount);
```

### ExecuteCalled
Emitted when an arbitrary call is executed from the contract


```solidity
event ExecuteCalled(address indexed to, uint256 value, bytes data);
```

