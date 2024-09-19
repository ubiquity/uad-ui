// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

interface IUbiquityAmoMinter {
    /**
     * @notice Enables an AMO for collateral transfers
     * @param amo Address of the AMO to enable
     */
    function enableAmo(address amo) external;

    /**
     * @notice Disables an AMO, preventing further collateral transfers
     * @param amo Address of the AMO to disable
     */
    function disableAmo(address amo) external;

    /**
     * @notice Transfers collateral to a specified AMO
     * @param destinationAmo Address of the AMO to receive collateral
     * @param collateralAmount Amount of collateral to transfer
     */
    function giveCollateralToAmo(
        address destinationAmo,
        uint256 collateralAmount
    ) external;

    /**
     * @notice Receives collateral back from an AMO
     * @param collateralAmount Amount of collateral being returned
     */
    function receiveCollateralFromAmo(uint256 collateralAmount) external;

    /**
     * @notice Updates the maximum allowable borrowed collateral
     * @param _collateralBorrowCap New collateral borrow cap value
     */
    function setCollateralBorrowCap(uint256 _collateralBorrowCap) external;

    /**
     * @notice Updates the address of the Ubiquity pool
     * @param _poolAddress New pool address
     */
    function setPool(address _poolAddress) external;

    /**
     * @notice Returns the total balance of collateral borrowed by all AMOs
     * @return Total balance of collateral borrowed
     */
    function collateralDollarBalance() external view returns (uint256);

    /**
     * @notice Emitted when collateral is given to an AMO
     * @param destinationAmo Address of the AMO receiving the collateral
     * @param collateralAmount Amount of collateral transferred
     */
    event CollateralGivenToAmo(
        address destinationAmo,
        uint256 collateralAmount
    );

    /**
     * @notice Emitted when collateral is returned from an AMO
     * @param sourceAmo Address of the AMO returning the collateral
     * @param collateralAmount Amount of collateral returned
     */
    event CollateralReceivedFromAmo(
        address sourceAmo,
        uint256 collateralAmount
    );

    /**
     * @notice Emitted when the collateral borrow cap is updated
     * @param newCollateralBorrowCap The updated collateral borrow cap
     */
    event CollateralBorrowCapSet(uint256 newCollateralBorrowCap);

    /**
     * @notice Emitted when the Ubiquity pool address is updated
     * @param newPoolAddress The updated pool address
     */
    event PoolSet(address newPoolAddress);

    /**
     * @notice Emitted when ownership of the contract is transferred
     * @param newOwner Address of the new contract owner
     */
    event OwnershipTransferred(address newOwner);
}
