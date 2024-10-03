# ICurveStableSwapMetaNG
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/interfaces/ICurveStableSwapMetaNG.sol)

**Inherits:**
IERC20

Curve MetaPool interface

**What is Curve MetaPool**

The pool that consists of 2 tokens: stable coin and 3CRV LP token.
For example the pool may contain Ubiquity Dollar and 3CRV LP token.
This allows users to trade between Ubiquity Dollar and any of the tokens
from the Curve 3Pool (DAI, USDC, USDT). When user adds liquidity to the pool
then he is rewarded with MetaPool LP tokens. 1 Dollar3CRV LP token != 1 stable coin token.

Add liquidity example:
1. User sends 100 Ubiquity Dollars to the pool
2. User gets 100 Dollar3CRV LP tokens of the pool

Remove liquidity example:
1. User sends 100 Dollar3CRV LP tokens to the pool
2. User gets 100 Dollar/DAI/USDC/USDT (may choose any) tokens

*Source: https://github.com/curvefi/stableswap-ng/blob/bff1522b30819b7b240af17ccfb72b0effbf6c47/contracts/main/CurveStableSwapMetaNG.vy*

*Docs: https://docs.curve.fi/stableswap-exchange/stableswap-ng/pools/metapool/*


## Functions
### add_liquidity

Deposits coins into to the pool and mints new LP tokens


```solidity
function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount, address _receiver)
    external
    returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amounts`|`uint256[2]`|List of amounts of underlying coins to deposit. Amounts correspond to the tokens at the same index locations within `coins`.|
|`_min_mint_amount`|`uint256`|Minimum amount of LP tokens to mint from the deposit|
|`_receiver`|`address`|Optional address that receives the LP tokens. If not specified, they are sent to the caller.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The amount of LP tokens that were minted in the deposit|


### balances

Getter for the current balance of coin `i` within the pool


```solidity
function balances(uint256 i) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`i`|`uint256`|Coin index|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Coin balance|


### calc_token_amount

Estimates the amount of LP tokens minted or burned based on a deposit or withdrawal

This calculation accounts for slippage, but not fees. It should be used as a basis for
determining expected amounts when calling `add_liquidity()` or `remove_liquidity_imbalance()`,
but should not be considered to be precise!


```solidity
function calc_token_amount(uint256[2] memory _amounts, bool _is_deposit) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amounts`|`uint256[2]`|Amount of each coin being deposited. Amounts correspond to the tokens at the same index locations within `coins()`.|
|`_is_deposit`|`bool`|Set `True` for deposits, `False` for withdrawals|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The expected amount of LP tokens minted or burned|


### coins

Returns token address by the provided `arg0` index


```solidity
function coins(uint256 arg0) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`arg0`|`uint256`|Token index|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Token address|


### exchange

Performs an exchange between two tokens. Index values can be found
using the `coins()` public getter method, or `get_coins()` within the factory contract.


```solidity
function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`i`|`int128`|Index value of the token to send|
|`j`|`int128`|Index value of the token to receive|
|`dx`|`uint256`|The amount of `i` being exchanged|
|`min_dy`|`uint256`|The minimum amount of `j` to receive. If the swap would result in less, the transaction will revert.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The amount of `j` received in the exchange|


### price_oracle

Function to calculate the exponential moving average (ema) price for the coin at index value `i`


```solidity
function price_oracle(uint256 i) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`i`|`uint256`|Index value of coin|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Price oracle|


### remove_liquidity_one_coin

Withdraws a single asset from the pool


```solidity
function remove_liquidity_one_coin(uint256 _burn_amount, int128 i, uint256 _min_received) external returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_burn_amount`|`uint256`|Amount of LP tokens to burn in the withdrawal|
|`i`|`int128`|Index value of the coin to withdraw. Can be found using the `coins()` getter method.|
|`_min_received`|`uint256`|Minimum amount of the coin to receive|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The amount of the coin received in the withdrawal|


