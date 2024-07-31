# MockCurveFactory
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/mocks/MockCurveFactory.sol)

**Inherits:**
[ICurveFactory](/src/dollar/interfaces/ICurveFactory.sol/interface.ICurveFactory.md)


## Functions
### deploy_metapool


```solidity
function deploy_metapool(address _base_pool, string memory, string memory, address _coin, uint256, uint256)
    external
    returns (address);
```

### find_pool_for_coins


```solidity
function find_pool_for_coins(address _from, address _to) external view returns (address);
```

### find_pool_for_coins


```solidity
function find_pool_for_coins(address _from, address _to, uint256 i) external view returns (address);
```

### get_n_coins


```solidity
function get_n_coins(address _pool) external view returns (uint256, uint256);
```

### get_coins


```solidity
function get_coins(address _pool) external view returns (address[2] memory);
```

### get_underlying_coins


```solidity
function get_underlying_coins(address _pool) external view returns (address[8] memory);
```

### get_decimals


```solidity
function get_decimals(address _pool) external view returns (uint256[2] memory);
```

### get_underlying_decimals


```solidity
function get_underlying_decimals(address _pool) external view returns (uint256[8] memory);
```

### get_rates


```solidity
function get_rates(address _pool) external view returns (uint256[2] memory);
```

### get_balances


```solidity
function get_balances(address _pool) external view returns (uint256[2] memory);
```

### get_underlying_balances


```solidity
function get_underlying_balances(address _pool) external view returns (uint256[8] memory);
```

### get_A


```solidity
function get_A(address _pool) external view returns (uint256);
```

### get_fees


```solidity
function get_fees(address _pool) external view returns (uint256, uint256);
```

### get_admin_balances


```solidity
function get_admin_balances(address _pool) external view returns (uint256[2] memory);
```

### get_coin_indices


```solidity
function get_coin_indices(address _pool, address _from, address _to) external view returns (int128, int128, bool);
```

### add_base_pool


```solidity
function add_base_pool(address _base_pool, address _metapool_implementation, address _fee_receiver) external;
```

### commit_transfer_ownership


```solidity
function commit_transfer_ownership(address addr) external;
```

### accept_transfer_ownership


```solidity
function accept_transfer_ownership() external;
```

### set_fee_receiver


```solidity
function set_fee_receiver(address _base_pool, address _fee_receiver) external;
```

### convert_fees


```solidity
function convert_fees() external returns (bool);
```

### admin


```solidity
function admin() external view returns (address);
```

### future_admin


```solidity
function future_admin() external view returns (address);
```

### pool_list


```solidity
function pool_list(uint256 arg0) external view returns (address);
```

### pool_count


```solidity
function pool_count() external view returns (uint256);
```

### base_pool_list


```solidity
function base_pool_list(uint256 arg0) external view returns (address);
```

### base_pool_count


```solidity
function base_pool_count() external view returns (uint256);
```

### fee_receiver


```solidity
function fee_receiver(address arg0) external view returns (address);
```

