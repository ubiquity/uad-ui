// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LibDiamond} from "./LibDiamond.sol";
import {LibAccessControl} from "./LibAccessControl.sol";
import "./Constants.sol";

/// @notice Shared struct used as a storage in the `LibAppStorage` library
struct AppStorage {
    // reentrancy guard
    uint256 reentrancyStatus;
    // others
    address dollarTokenAddress;
    address creditNftAddress;
    address creditNftCalculatorAddress;
    address dollarMintCalculatorAddress;
    address stakingShareAddress;
    address stakingContractAddress;
    address stableSwapMetaPoolAddress;
    address stableSwapPlainPoolAddress;
    address curve3PoolTokenAddress; // 3CRV
    address treasuryAddress;
    address governanceTokenAddress;
    address sushiSwapPoolAddress; // sushi pool UbiquityDollar-GovernanceToken
    address masterChefAddress;
    address formulasAddress;
    address creditTokenAddress;
    address creditCalculatorAddress;
    address ubiquiStickAddress;
    address bondingCurveAddress;
    address bancorFormulaAddress;
    address curveDollarIncentiveAddress;
    mapping(address => address) _excessDollarDistributors;
    // pausable
    bool paused;
}

/// @notice Library used as a shared storage among all protocol libraries
library LibAppStorage {
    /**
     * @notice Returns `AppStorage` struct used as a shared storage among all libraries
     * @return ds `AppStorage` struct used as a shared storage
     */
    function appStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}

/// @notice Contract includes modifiers shared across all protocol's contracts
contract Modifiers {
    /// @notice Shared struct used as a storage across all protocol's contracts
    AppStorage internal store;

    /**
     * @notice Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     *
     * @dev Works identically to OZ's nonReentrant.
     * @dev Used to avoid state storage collision within diamond.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(
            store.reentrancyStatus != _ENTERED,
            "ReentrancyGuard: reentrant call"
        );

        // Any calls to nonReentrant after this point will fail
        store.reentrancyStatus = _ENTERED;
        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        store.reentrancyStatus = _NOT_ENTERED;
    }

    /// @notice Checks that method is called by a contract owner
    modifier onlyOwner() {
        LibDiamond.enforceIsContractOwner();
        _;
    }

    /// @notice Checks that method is called by address with the `CREDIT_NFT_MANAGER_ROLE` role
    modifier onlyCreditNftManager() {
        require(
            LibAccessControl.hasRole(CREDIT_NFT_MANAGER_ROLE, msg.sender),
            "Caller is not a Credit NFT manager"
        );
        _;
    }

    /// @notice Checks that method is called by address with the `DEFAULT_ADMIN_ROLE` role
    modifier onlyAdmin() {
        require(
            LibAccessControl.hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Manager: Caller is not admin"
        );
        _;
    }

    /// @notice Checks that method is called by address with the `GOVERNANCE_TOKEN_MINTER_ROLE` role
    modifier onlyMinter() {
        require(
            LibAccessControl.hasRole(GOVERNANCE_TOKEN_MINTER_ROLE, msg.sender),
            "Governance token: not minter"
        );
        _;
    }

    /// @notice Checks that method is called by address with the `GOVERNANCE_TOKEN_BURNER_ROLE` role
    modifier onlyBurner() {
        require(
            LibAccessControl.hasRole(GOVERNANCE_TOKEN_BURNER_ROLE, msg.sender),
            "Governance token: not burner"
        );
        _;
    }

    /// @notice Modifier to make a function callable only when the contract is not paused
    modifier whenNotPaused() {
        require(!LibAccessControl.paused(), "Pausable: paused");
        _;
    }

    /// @notice Modifier to make a function callable only when the contract is paused
    modifier whenPaused() {
        require(LibAccessControl.paused(), "Pausable: not paused");
        _;
    }

    /// @notice Checks that method is called by address with the `STAKING_MANAGER_ROLE` role
    modifier onlyStakingManager() {
        require(
            LibAccessControl.hasRole(STAKING_MANAGER_ROLE, msg.sender),
            "not manager"
        );
        _;
    }

    /// @notice Checks that method is called by address with the `PAUSER_ROLE` role
    modifier onlyPauser() {
        require(
            LibAccessControl.hasRole(PAUSER_ROLE, msg.sender),
            "not pauser"
        );
        _;
    }

    /// @notice Checks that method is called by address with the `GOVERNANCE_TOKEN_MANAGER_ROLE` role
    modifier onlyTokenManager() {
        require(
            LibAccessControl.hasRole(GOVERNANCE_TOKEN_MANAGER_ROLE, msg.sender),
            "MasterChef: not Governance Token manager"
        );
        _;
    }

    /// @notice Checks that method is called by address with the `INCENTIVE_MANAGER_ROLE` role
    modifier onlyIncentiveAdmin() {
        require(
            LibAccessControl.hasRole(INCENTIVE_MANAGER_ROLE, msg.sender),
            "CreditCalc: not admin"
        );
        _;
    }

    /// @notice Checks that method is called by address with the `CURVE_DOLLAR_MANAGER_ROLE` role
    modifier onlyDollarManager() {
        require(
            LibAccessControl.hasRole(CURVE_DOLLAR_MANAGER_ROLE, msg.sender),
            "CurveIncentive: Caller is not Ubiquity Dollar"
        );
        _;
    }

    /// @notice Initializes reentrancy guard on contract deployment
    function _initReentrancyGuard() internal {
        store.reentrancyStatus = _NOT_ENTERED;
    }
}
