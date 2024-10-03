# IDepositZap
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/interfaces/IDepositZap.sol)

Interface for Curve's Deposit Zap

Deposit contracts (also known as “zaps”) allow users to add and remove liquidity
from a pool using the pool’s underlying tokens


## Functions
### add_liquidity

Wrap underlying coins and deposit them into `_pool`


```solidity
function add_liquidity(address _pool, uint256[4] calldata _amounts, uint256 _min_mint_amount)
    external
    returns (uint256 lpAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pool`|`address`|Address of the pool to deposit into|
|`_amounts`|`uint256[4]`|List of amounts of underlying coins to deposit|
|`_min_mint_amount`|`uint256`|Minimum amount of LP tokens to mint from the deposit|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`lpAmount`|`uint256`|Amount of LP tokens received by depositing|


### remove_liquidity_one_coin

Withdraw and unwrap a single coin from the pool


```solidity
function remove_liquidity_one_coin(address _pool, uint256 lpAmount, int128 i, uint256 min_amount)
    external
    returns (uint256 coinAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pool`|`address`|Address of the pool to withdraw from|
|`lpAmount`|`uint256`|Amount of LP tokens to burn in the withdrawal|
|`i`|`int128`|Index value of the coin to withdraw|
|`min_amount`|`uint256`|Minimum amount of underlying coin to receive|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`coinAmount`|`uint256`|Amount of underlying coin received|


### remove_liquidity

Withdraw and unwrap coins from the pool

*Withdrawal amounts are based on current deposit ratios*


```solidity
function remove_liquidity(address _pool, uint256 _amount, uint256[4] calldata min_amounts)
    external
    returns (uint256[4] calldata);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pool`|`address`|Address of the pool to deposit into|
|`_amount`|`uint256`|Quantity of LP tokens to burn in the withdrawal|
|`min_amounts`|`uint256[4]`|Minimum amounts of underlying coins to receive|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[4]`|List of amounts of underlying coins that were withdrawn|


