# MockCurveStableSwapMetaNG
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/mocks/MockCurveStableSwapMetaNG.sol)

**Inherits:**
[ICurveStableSwapMetaNG](/src/dollar/interfaces/ICurveStableSwapMetaNG.sol/interface.ICurveStableSwapMetaNG.md), [MockERC20](/src/dollar/mocks/MockERC20.sol/contract.MockERC20.md)


## State Variables
### token0

```solidity
address token0;
```


### token1

```solidity
address token1;
```


### coins

```solidity
address[2] public coins;
```


### priceOracle

```solidity
uint256 priceOracle = 1e18;
```


## Functions
### constructor


```solidity
constructor(address _token0, address _token1) MockERC20("Mock", "MCK", 18);
```

### add_liquidity


```solidity
function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount, address _receiver)
    public
    returns (uint256 result);
```

### balances


```solidity
function balances(uint256) external pure returns (uint256);
```

### calc_token_amount


```solidity
function calc_token_amount(uint256[2] memory _amounts, bool) external pure returns (uint256);
```

### exchange


```solidity
function exchange(int128, int128, uint256, uint256) external pure returns (uint256);
```

### price_oracle


```solidity
function price_oracle(uint256) external view returns (uint256);
```

### remove_liquidity_one_coin


```solidity
function remove_liquidity_one_coin(uint256, int128, uint256) external pure returns (uint256);
```

### updateMockParams


```solidity
function updateMockParams(uint256 _priceOracle) public;
```

