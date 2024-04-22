// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ICurveStableSwapNG} from "../interfaces/ICurveStableSwapNG.sol";
import {MockCurveStableSwapMetaNG} from "./MockCurveStableSwapMetaNG.sol";

contract MockCurveStableSwapNG is
    ICurveStableSwapNG,
    MockCurveStableSwapMetaNG
{
    constructor(
        address _token0,
        address _token1
    ) MockCurveStableSwapMetaNG(_token0, _token1) {}
}
