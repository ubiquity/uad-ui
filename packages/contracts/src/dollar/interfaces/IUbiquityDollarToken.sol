// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import "./IERC20Ubiquity.sol";

/**
 * @notice Ubiquity Dollar token interface
 */
interface IUbiquityDollarToken is IERC20Ubiquity {
    function pause() external;
    function unpause() external;

    /// @notice Emitted on setting an incentive contract for an account
    event IncentiveContractUpdate(
        address indexed _incentivized,
        address indexed _incentiveContract
    );

    /**
     * @notice Sets `incentive` contract for `account`
     * @notice Incentive contracts are applied on Dollar transfers:
     * - EOA => contract
     * - contract => EOA
     * - contract => contract
     * - any transfer global incentive
     * @param account Account to incentivize
     * @param incentive Incentive contract address
     */
    function setIncentiveContract(address account, address incentive) external;

    /**
     * @notice Returns incentive contract address for `account`
     * @dev Address is 0 if there is no incentive contract for the account
     * @param account Address for which we should retrieve an incentive contract
     * @return Incentive contract address
     */
    function incentiveContract(address account) external view returns (address);
}
