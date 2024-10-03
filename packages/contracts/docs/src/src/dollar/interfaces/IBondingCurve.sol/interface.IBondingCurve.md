# IBondingCurve
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/interfaces/IBondingCurve.sol)

Interface based on Bancor formula

Inspired from Bancor protocol https://github.com/bancorprotocol/contracts

Used on UbiquiStick NFT minting


## Functions
### setParams

Sets bonding curve params


```solidity
function setParams(uint32 _connectorWeight, uint256 _baseY) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_connectorWeight`|`uint32`|Connector weight|
|`_baseY`|`uint256`|Base Y|


### connectorWeight

Returns `connectorWeight` value


```solidity
function connectorWeight() external returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Connector weight value|


### baseY

Returns `baseY` value


```solidity
function baseY() external returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Base Y value|


### poolBalance

Returns total balance of deposited collateral


```solidity
function poolBalance() external returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of deposited collateral|


### deposit

Deposits collateral tokens in exchange for UbiquiStick NFT


```solidity
function deposit(uint256 _collateralDeposited, address _recipient) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_collateralDeposited`|`uint256`|Amount of collateral|
|`_recipient`|`address`|Address to receive the NFT|


### withdraw

Withdraws collateral tokens to treasury


```solidity
function withdraw(uint256 _amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|Amount of collateral tokens to withdraw|


