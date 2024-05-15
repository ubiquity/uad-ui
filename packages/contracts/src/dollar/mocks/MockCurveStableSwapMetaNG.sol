// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ICurveStableSwapMetaNG} from "../interfaces/ICurveStableSwapMetaNG.sol";
import {MockERC20} from "./MockERC20.sol";

contract MockCurveStableSwapMetaNG is ICurveStableSwapMetaNG, MockERC20 {
    address token0;
    address token1;
    address[2] public coins;
    uint256 priceOracle = 1e18;

    constructor(address _token0, address _token1) MockERC20("Mock", "MCK", 18) {
        coins[0] = _token0;
        coins[1] = _token1;
    }

    function add_liquidity(
        uint256[2] memory _amounts,
        uint256 _min_mint_amount,
        address _receiver
    ) public returns (uint256 result) {
        mint(
            _receiver,
            _min_mint_amount == 0
                ? _amounts[0] > _amounts[1] ? _amounts[0] : _amounts[1]
                : _min_mint_amount
        );
        return result;
    }

    function balances(uint256 /* i */) external pure returns (uint256) {
        return 0;
    }

    function calc_token_amount(
        uint256[2] memory _amounts,
        bool /* _is_deposit */
    ) external pure returns (uint256) {
        return _amounts[0] > _amounts[1] ? _amounts[0] : _amounts[1];
    }

    function exchange(
        int128 /* i */,
        int128 /* j */,
        uint256 /* dx */,
        uint256 /* min_dy */
    ) external pure returns (uint256) {
        return 0;
    }

    function get_dy(
        int128 /* i */,
        int128 /*j */,
        uint256 dx
    ) external pure returns (uint256) {
        return dx;
    }

    function price_oracle(uint256 /* i */) external view returns (uint256) {
        return priceOracle;
    }

    function remove_liquidity_one_coin(
        uint256 /* _burn_amount */,
        int128 /* i */,
        uint256 /* _min_received */
    ) external pure returns (uint256) {
        return 0;
    }

    function updateMockParams(uint256 _priceOracle) public {
        priceOracle = _priceOracle;
    }
}
