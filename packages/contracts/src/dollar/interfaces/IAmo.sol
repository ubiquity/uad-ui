// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IAmo {
    /**
     * @notice Returns collateral back to the AMO minter
     * @param collateralAmount Amount of collateral to return
     */
    function returnCollateralToMinter(uint256 collateralAmount) external;

    /**
     * @notice Sets the address of the AMO minter
     * @param _amoMinterAddress New address of the AMO minter
     */
    function setAmoMinter(address _amoMinterAddress) external;
}
