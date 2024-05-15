// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

/**
 * @notice Curve MetaPool interface
 *
 * @notice **What is Curve MetaPool**
 * @notice The pool that consists of 2 tokens: stable coin and 3CRV LP token.
 * For example the pool may contain Ubiquity Dollar and 3CRV LP token.
 * This allows users to trade between Ubiquity Dollar and any of the tokens
 * from the Curve 3Pool (DAI, USDC, USDT). When user adds liquidity to the pool
 * then he is rewarded with MetaPool LP tokens. 1 Dollar3CRV LP token != 1 stable coin token.
 * @notice Add liquidity example:
 * 1. User sends 100 Ubiquity Dollars to the pool
 * 2. User gets 100 Dollar3CRV LP tokens of the pool
 * @notice Remove liquidity example:
 * 1. User sends 100 Dollar3CRV LP tokens to the pool
 * 2. User gets 100 Dollar/DAI/USDC/USDT (may choose any) tokens
 *
 * @dev Source: https://github.com/curvefi/stableswap-ng/blob/bff1522b30819b7b240af17ccfb72b0effbf6c47/contracts/main/CurveStableSwapMetaNG.vy
 * @dev Docs: https://docs.curve.fi/stableswap-exchange/stableswap-ng/pools/metapool/
 */
interface ICurveStableSwapMetaNG is IERC20 {
    /**
     * @notice Deposits coins into to the pool and mints new LP tokens
     * @param _amounts List of amounts of underlying coins to deposit.
     * Amounts correspond to the tokens at the same index locations within `coins`.
     * @param _min_mint_amount Minimum amount of LP tokens to mint from the deposit
     * @param _receiver Optional address that receives the LP tokens. If not specified, they are sent to the caller.
     * @return The amount of LP tokens that were minted in the deposit
     */
    function add_liquidity(
        uint256[2] memory _amounts,
        uint256 _min_mint_amount,
        address _receiver
    ) external returns (uint256);

    /**
     * @notice Getter for the current balance of coin `i` within the pool
     * @param i Coin index
     * @return Coin balance
     */
    function balances(uint256 i) external view returns (uint256);

    /**
     * @notice Estimates the amount of LP tokens minted or burned based on a deposit or withdrawal
     *
     * @notice This calculation accounts for slippage, but not fees. It should be used as a basis for
     * determining expected amounts when calling `add_liquidity()` or `remove_liquidity_imbalance()`,
     * but should not be considered to be precise!
     *
     * @param _amounts Amount of each coin being deposited. Amounts correspond to the tokens at the
     * same index locations within `coins()`.
     * @param _is_deposit Set `True` for deposits, `False` for withdrawals
     * @return The expected amount of LP tokens minted or burned
     */
    function calc_token_amount(
        uint256[2] memory _amounts,
        bool _is_deposit
    ) external view returns (uint256);

    /**
     * @notice Returns token address by the provided `arg0` index
     * @param arg0 Token index
     * @return Token address
     */
    function coins(uint256 arg0) external view returns (address);

    /**
     * @notice Performs an exchange between two tokens. Index values can be found
     * using the `coins()` public getter method, or `get_coins()` within the factory contract.
     * @param i Index value of the token to send
     * @param j Index value of the token to receive
     * @param dx The amount of `i` being exchanged
     * @param min_dy The minimum amount of `j` to receive. If the swap would result in less, the transaction will revert.
     * @return The amount of `j` received in the exchange
     */
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    /**
     * @notice Function to calculate the predicted output amount of token `j` to receive at the pool's 
     * current state given an input of `dx` amount of coin `i`.
     * @param i Index value of input coin
     * @param j Index value of output coin
     * @param dx Amount of input coin being exchanged
     * @return Predicted output amount of j
     */
    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external returns (uint256);

    /**
     * @notice Function to calculate the exponential moving average (ema) price for the coin at index value `i`
     * @param i Index value of coin
     * @return Price oracle
     */
    function price_oracle(uint256 i) external view returns (uint256);

    /**
     * @notice Withdraws a single asset from the pool
     * @param _burn_amount Amount of LP tokens to burn in the withdrawal
     * @param i Index value of the coin to withdraw. Can be found using the `coins()` getter method.
     * @param _min_received Minimum amount of the coin to receive
     * @return The amount of the coin received in the withdrawal
     */
    function remove_liquidity_one_coin(
        uint256 _burn_amount,
        int128 i,
        uint256 _min_received
    ) external returns (uint256);
}
