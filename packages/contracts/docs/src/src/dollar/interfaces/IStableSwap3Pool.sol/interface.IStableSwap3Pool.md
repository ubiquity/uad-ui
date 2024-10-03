# IStableSwap3Pool
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/interfaces/IStableSwap3Pool.sol)

Curve TriPool interface


## Functions
### get_virtual_price

The current virtual price of the pool LP token

*Useful for calculating profits*


```solidity
function get_virtual_price() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|LP token virtual price normalized to 1e18|


### balances

Returns pool balance


```solidity
function balances(uint256) external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Token balance|


### coins

Returns coin address by index


```solidity
function coins(uint256) external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Coin address|


### get_dy

Calculates the price for exchanging a token with index `i` to token
with index `j` and amount `dx` given the `_balances` provided


```solidity
function get_dy(int128 i, int128 j, uint256 dx) external view returns (uint256 dy);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`i`|`int128`|The index of the coin being sent to the pool, as it related to the metapool|
|`j`|`int128`|The index of the coin being received from the pool, as it relates to the metapool|
|`dx`|`uint256`|The amount of `i` being sent to the pool|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`dy`|`uint256`|Returns the quote / price as `dy` given `dx`|


### exchange

Performs an exchange between two tokens. Index values can be found
using the `coins()` public getter method, or `get_coins()` within the factory contract.


```solidity
function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`i`|`int128`|Index value of the token to send|
|`j`|`int128`|Index value of the token to receive|
|`dx`|`uint256`|The amount of `i` being exchanged|
|`min_dy`|`uint256`|The minimum amount of `j` to receive. If the swap would result in less, the transaction will revert.|


### add_liquidity

Deposits coins into to the pool and mints new LP tokens


```solidity
function add_liquidity(uint256[3] calldata amounts, uint256 min_mint_amount) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amounts`|`uint256[3]`|List of amounts of underlying coins to deposit. Amounts correspond to the tokens at the same index locations within `coins`.|
|`min_mint_amount`|`uint256`|Minimum amount of LP tokens to mint from the deposit|


### remove_liquidity

Withdraw coins from the pool

*Withdrawal amounts are based on current deposit ratios*


```solidity
function remove_liquidity(uint256 _amount, uint256[3] calldata amounts) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|Quantity of LP tokens to burn in the withdrawal|
|`amounts`|`uint256[3]`|Minimum amounts of underlying coins to receive|


### remove_liquidity_one_coin

Withdraw a single coin from the pool


```solidity
function remove_liquidity_one_coin(uint256 _token_amount, int128 i, uint256 min_amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token_amount`|`uint256`|Amount of LP tokens to burn in the withdrawal|
|`i`|`int128`|Index value of the coin to withdraw|
|`min_amount`|`uint256`|Minimum amount of coin to receive|


### calc_token_amount

Calculate addition or reduction in token supply from a deposit or withdrawal

*This calculation accounts for slippage, but not fees.
Needed to prevent front-running, not for precise calculations!*


```solidity
function calc_token_amount(uint256[3] calldata amounts, bool deposit) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amounts`|`uint256[3]`|Amount of each coin being deposited|
|`deposit`|`bool`|set True for deposits, False for withdrawals|


### calc_withdraw_one_coin

Calculate the amount received when withdrawing a single coin


```solidity
function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token_amount`|`uint256`|Amount of LP tokens to burn in the withdrawal|
|`i`|`int128`|Index value of the coin to withdraw|


