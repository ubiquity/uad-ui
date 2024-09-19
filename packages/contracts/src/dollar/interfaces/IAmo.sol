// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IAmo {
    function returnCollateralToMinter(uint256 collateralAmount) external;

    function setAmoMinter(address _amoMinterAddress) external;
}
