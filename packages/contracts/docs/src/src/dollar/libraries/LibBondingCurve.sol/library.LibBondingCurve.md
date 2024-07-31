# LibBondingCurve
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/libraries/LibBondingCurve.sol)

Bonding curve library based on Bancor formula

Inspired from Bancor protocol https://github.com/bancorprotocol/contracts

Used on UbiquiStick NFT minting


## State Variables
### BONDING_CONTROL_STORAGE_SLOT
Storage slot used to store data for this library


```solidity
bytes32 constant BONDING_CONTROL_STORAGE_SLOT =
    bytes32(uint256(keccak256("ubiquity.contracts.bonding.storage")) - 1) & ~bytes32(uint256(0xff));
```


## Functions
### bondingCurveStorage

Returns struct used as a storage for this library


```solidity
function bondingCurveStorage() internal pure returns (BondingCurveData storage l);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`l`|`BondingCurveData`|Struct used as a storage|


### setParams

Sets bonding curve params


```solidity
function setParams(uint32 _connectorWeight, uint256 _baseY) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_connectorWeight`|`uint32`|Connector weight|
|`_baseY`|`uint256`|Base Y|


### connectorWeight

Returns `connectorWeight` value


```solidity
function connectorWeight() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Connector weight value|


### baseY

Returns `baseY` value


```solidity
function baseY() internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Base Y value|


### poolBalance

Returns total balance of deposited collateral


```solidity
function poolBalance() internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of deposited collateral|


### deposit

Deposits collateral tokens in exchange for UbiquiStick NFT


```solidity
function deposit(uint256 _collateralDeposited, address _recipient) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_collateralDeposited`|`uint256`|Amount of collateral|
|`_recipient`|`address`|Address to receive the NFT|


### getShare

Returns number of NFTs a `_recipient` holds


```solidity
function getShare(address _recipient) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipient`|`address`|User address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of NFTs for `_recipient`|


### toBytes

Converts `x` to `bytes`


```solidity
function toBytes(uint256 x) internal pure returns (bytes memory b);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`uint256`|Value to convert to `bytes`|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`b`|`bytes`|`x` value converted to `bytes`|


### withdraw

Withdraws collateral tokens to treasury


```solidity
function withdraw(uint256 _amount) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|Amount of collateral tokens to withdraw|


### purchaseTargetAmount

Given a token supply, reserve balance, weight and a deposit amount (in the reserve token),
calculates the target amount for a given conversion (in the main token)

`_supply * ((1 + _tokensDeposited / _connectorBalance) ^ (_connectorWeight / 1000000) - 1)`


```solidity
function purchaseTargetAmount(
    uint256 _tokensDeposited,
    uint32 _connectorWeight,
    uint256 _supply,
    uint256 _connectorBalance
) internal pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokensDeposited`|`uint256`|Amount of collateral tokens to deposit|
|`_connectorWeight`|`uint32`|Connector weight, represented in ppm, 1 - 1,000,000|
|`_supply`|`uint256`|Current token supply|
|`_connectorBalance`|`uint256`|Total connector balance|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of tokens minted|


### purchaseTargetAmountFromZero

Given a deposit (in the collateral token) token supply of 0, calculates the return
for a given conversion (in the token)

`_supply * ((1 + _tokensDeposited / _connectorBalance) ^ (_connectorWeight / 1000000) - 1)`


```solidity
function purchaseTargetAmountFromZero(
    uint256 _tokensDeposited,
    uint256 _connectorWeight,
    uint256 _baseX,
    uint256 _baseY
) internal pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokensDeposited`|`uint256`|Amount of collateral tokens to deposit|
|`_connectorWeight`|`uint256`|Connector weight, represented in ppm, 1 - 1,000,000|
|`_baseX`|`uint256`|Constant x|
|`_baseY`|`uint256`|Expected price|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of tokens minted|


### uintToBytes16

Converts `x` to `bytes16`


```solidity
function uintToBytes16(uint256 x) internal pure returns (bytes16 b);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`uint256`|Value to convert to `bytes16`|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`b`|`bytes16`|`x` value converted to `bytes16`|


## Events
### Deposit
Emitted when collateral is deposited


```solidity
event Deposit(address indexed user, uint256 amount);
```

### Withdraw
Emitted when collateral is withdrawn


```solidity
event Withdraw(uint256 amount);
```

### ParamsSet
Emitted when parameters are updated


```solidity
event ParamsSet(uint32 connectorWeight, uint256 baseY);
```

## Structs
### BondingCurveData
Struct used as a storage for the current library


```solidity
struct BondingCurveData {
    uint32 connectorWeight;
    uint256 baseY;
    uint256 poolBalance;
    uint256 tokenIds;
    mapping(address => uint256) share;
}
```

