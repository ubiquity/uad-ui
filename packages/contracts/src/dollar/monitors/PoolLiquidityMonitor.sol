// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../facets/UbiquityPoolFacet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PoolLiquidityMonitor is Ownable {
    UbiquityPoolFacet public immutable ubiquityPoolFacet;
    address public defenderRelayer;

    event LiquidityChecked(uint256 currentLiquidity);

    constructor(address _ubiquityPoolFacetAddress, address _defenderRelayer) {
        ubiquityPoolFacet = UbiquityPoolFacet(_ubiquityPoolFacetAddress);
        defenderRelayer = _defenderRelayer;
    }

    modifier onlyAuthorized() {
        require(
            msg.sender == defenderRelayer,
            "Not authorized: Only Defender Relayer allowed"
        );
        _;
    }

    function setDefenderRelayer(
        address _newDefenderRelayer
    ) external onlyOwner {
        defenderRelayer = _newDefenderRelayer;
    }

    function checkLiquidity() external onlyAuthorized {
        uint256 currentCollateralLiquidity = ubiquityPoolFacet
            .collateralUsdBalance();

        emit LiquidityChecked(currentCollateralLiquidity);
    }
}
