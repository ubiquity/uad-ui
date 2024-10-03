# ICurveFactory
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/interfaces/ICurveFactory.sol)

Curve Factory interface

Permissionless pool deployer and registry


## Functions
### find_pool_for_coins

Finds an available pool for exchanging two coins


```solidity
function find_pool_for_coins(address _from, address _to) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|Address of coin to be sent|
|`_to`|`address`|Address of coin to be received|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Pool address|


### find_pool_for_coins

Finds an available pool for exchanging two coins


```solidity
function find_pool_for_coins(address _from, address _to, uint256 i) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|Address of coin to be sent|
|`_to`|`address`|Address of coin to be received|
|`i`|`uint256`|Index value. When multiple pools are available this value is used to return the n'th address.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Pool address|


### get_n_coins

Get the number of coins in a pool


```solidity
function get_n_coins(address _pool) external view returns (uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pool`|`address`|Pool address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Number of coins|
|`<none>`|`uint256`||


### get_coins

Get the coins within a pool


```solidity
function get_coins(address _pool) external view returns (address[2] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pool`|`address`|Pool address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[2]`|List of coin addresses|


### get_underlying_coins

Get the underlying coins within a pool

*Reverts if a pool does not exist or is not a metapool*


```solidity
function get_underlying_coins(address _pool) external view returns (address[8] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pool`|`address`|Pool address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[8]`|List of coin addresses|


### get_decimals

Get decimal places for each coin within a pool


```solidity
function get_decimals(address _pool) external view returns (uint256[2] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pool`|`address`|Pool address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[2]`|uint256 list of decimals|


### get_underlying_decimals

Get decimal places for each underlying coin within a pool


```solidity
function get_underlying_decimals(address _pool) external view returns (uint256[8] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pool`|`address`|Pool address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[8]`|uint256 list of decimals|


### get_rates

Get rates for coins within a pool


```solidity
function get_rates(address _pool) external view returns (uint256[2] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pool`|`address`|Pool address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[2]`|Rates for each coin, precision normalized to 10**18|


### get_balances

Get balances for each coin within a pool

*For pools using lending, these are the wrapped coin balances*


```solidity
function get_balances(address _pool) external view returns (uint256[2] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pool`|`address`|Pool address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[2]`|uint256 list of balances|


### get_underlying_balances

Get balances for each underlying coin within a metapool


```solidity
function get_underlying_balances(address _pool) external view returns (uint256[8] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pool`|`address`|Metapool address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[8]`|uint256 list of underlying balances|


### get_A

Get the amplfication co-efficient for a pool


```solidity
function get_A(address _pool) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pool`|`address`|Pool address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 A|


### get_fees

Get the fees for a pool

*Fees are expressed as integers*


```solidity
function get_fees(address _pool) external view returns (uint256, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Pool fee and admin fee as uint256 with 1e10 precision|
|`<none>`|`uint256`||


### get_admin_balances

Get the current admin balances (uncollected fees) for a pool


```solidity
function get_admin_balances(address _pool) external view returns (uint256[2] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pool`|`address`|Pool address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[2]`|List of uint256 admin balances|


### get_coin_indices

Convert coin addresses to indices for use with pool methods


```solidity
function get_coin_indices(address _pool, address _from, address _to) external view returns (int128, int128, bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pool`|`address`|Pool address|
|`_from`|`address`|Coin address to be used as `i` within a pool|
|`_to`|`address`|Coin address to be used as `j` within a pool|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|int128 `i`, int128 `j`, boolean indicating if `i` and `j` are underlying coins|
|`<none>`|`int128`||
|`<none>`|`bool`||


### add_base_pool

Add a base pool to the registry, which may be used in factory metapools

*Only callable by admin*


```solidity
function add_base_pool(address _base_pool, address _metapool_implementation, address _fee_receiver) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_base_pool`|`address`|Pool address to add|
|`_metapool_implementation`|`address`|Implementation address that can be used with this base pool|
|`_fee_receiver`|`address`|Admin fee receiver address for metapools using this base pool|


### deploy_metapool

Deploy a new metapool


```solidity
function deploy_metapool(
    address _base_pool,
    string memory _name,
    string memory _symbol,
    address _coin,
    uint256 _A,
    uint256 _fee
) external returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_base_pool`|`address`|Address of the base pool to use within the metapool|
|`_name`|`string`|Name of the new metapool|
|`_symbol`|`string`|Symbol for the new metapool - will be concatenated with the base pool symbol|
|`_coin`|`address`|Address of the coin being used in the metapool|
|`_A`|`uint256`|Amplification co-efficient - a higher value here means less tolerance for imbalance within the pool's assets. Suggested values include: Uncollateralized algorithmic stablecoins: 5-10 Non-redeemable, collateralized assets: 100 Redeemable assets: 200-400|
|`_fee`|`uint256`|Trade fee, given as an integer with 1e10 precision. The minimum fee is 0.04% (4000000), the maximum is 1% (100000000). 50% of the fee is distributed to veCRV holders.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Address of the deployed pool|


### commit_transfer_ownership

Transfer ownership of this contract to `addr`


```solidity
function commit_transfer_ownership(address addr) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`addr`|`address`|Address of the new owner|


### accept_transfer_ownership

Accept a pending ownership transfer

*Only callable by the new owner*


```solidity
function accept_transfer_ownership() external;
```

### set_fee_receiver

Set fee receiver for base and plain pools


```solidity
function set_fee_receiver(address _base_pool, address _fee_receiver) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_base_pool`|`address`|Address of base pool to set fee receiver for. For plain pools, leave as `ZERO_ADDRESS`.|
|`_fee_receiver`|`address`|Address that fees are sent to|


### convert_fees

Convert the fees of a pool and transfer to the pool's fee receiver

*All fees are converted to LP token of base pool*


```solidity
function convert_fees() external returns (bool);
```

### admin

Returns admin address


```solidity
function admin() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Admin address|


### future_admin

Returns future admin address


```solidity
function future_admin() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Fututre admin address|


### pool_list

Returns pool address by index


```solidity
function pool_list(uint256 arg0) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`arg0`|`uint256`|Pool index|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Pool address|


### pool_count

Returns `pool_list` length


```solidity
function pool_count() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Pool list length|


### base_pool_list

Returns base pool address by index


```solidity
function base_pool_list(uint256 arg0) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`arg0`|`uint256`|Base pool index|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Base pool address|


### base_pool_count

Returns `base_pool_list` length


```solidity
function base_pool_count() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Base pool list length|


### fee_receiver

Returns fee receiver by pool address


```solidity
function fee_receiver(address arg0) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`arg0`|`address`|Pool address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Fee receiver|


## Events
### BasePoolAdded
Emitted when a new base pool is added


```solidity
event BasePoolAdded(address base_pool, address implementat);
```

### MetaPoolDeployed
Emitted when a new MetaPool is deployed


```solidity
event MetaPoolDeployed(address coin, address base_pool, uint256 A, uint256 fee, address deployer);
```

