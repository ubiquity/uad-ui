# IUbiquityAmoMinter
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/interfaces/IUbiquityAmoMinter.sol)


## Functions
### enableAmo

Enables an AMO for collateral transfers


```solidity
function enableAmo(address amo) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amo`|`address`|Address of the AMO to enable|


### disableAmo

Disables an AMO, preventing further collateral transfers


```solidity
function disableAmo(address amo) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amo`|`address`|Address of the AMO to disable|


### giveCollateralToAmo

Transfers collateral to a specified AMO


```solidity
function giveCollateralToAmo(address destinationAmo, uint256 collateralAmount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`destinationAmo`|`address`|Address of the AMO to receive collateral|
|`collateralAmount`|`uint256`|Amount of collateral to transfer|


### receiveCollateralFromAmo

Receives collateral back from an AMO


```solidity
function receiveCollateralFromAmo(uint256 collateralAmount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralAmount`|`uint256`|Amount of collateral being returned|


### setCollateralBorrowCap

Updates the maximum allowable borrowed collateral


```solidity
function setCollateralBorrowCap(uint256 _collateralBorrowCap) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_collateralBorrowCap`|`uint256`|New collateral borrow cap value|


### setPool

Updates the address of the Ubiquity pool


```solidity
function setPool(address _poolAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_poolAddress`|`address`|New pool address|


### collateralDollarBalance

Returns the total balance of collateral borrowed by all AMOs


```solidity
function collateralDollarBalance() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Total balance of collateral borrowed|


## Events
### CollateralGivenToAmo
Emitted when collateral is given to an AMO


```solidity
event CollateralGivenToAmo(address destinationAmo, uint256 collateralAmount);
```

### CollateralReceivedFromAmo
Emitted when collateral is returned from an AMO


```solidity
event CollateralReceivedFromAmo(address sourceAmo, uint256 collateralAmount);
```

### CollateralBorrowCapSet
Emitted when the collateral borrow cap is updated


```solidity
event CollateralBorrowCapSet(uint256 newCollateralBorrowCap);
```

### PoolSet
Emitted when the Ubiquity pool address is updated


```solidity
event PoolSet(address newPoolAddress);
```

### OwnershipTransferred
Emitted when ownership of the contract is transferred


```solidity
event OwnershipTransferred(address newOwner);
```

