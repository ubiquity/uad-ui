// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "abdk/ABDKMathQuad.sol";

/// @dev Default admin role name
bytes32 constant DEFAULT_ADMIN_ROLE = 0x00;

/// @dev Role name for Governance tokens minter
bytes32 constant GOVERNANCE_TOKEN_MINTER_ROLE = keccak256(
    "GOVERNANCE_TOKEN_MINTER_ROLE"
);

/// @dev Role name for Governance tokens burner
bytes32 constant GOVERNANCE_TOKEN_BURNER_ROLE = keccak256(
    "GOVERNANCE_TOKEN_BURNER_ROLE"
);

/// @dev Role name for staking share minter
bytes32 constant STAKING_SHARE_MINTER_ROLE = keccak256(
    "STAKING_SHARE_MINTER_ROLE"
);

/// @dev Role name for staking share burner
bytes32 constant STAKING_SHARE_BURNER_ROLE = keccak256(
    "STAKING_SHARE_BURNER_ROLE"
);

/// @dev Role name for Credit tokens minter
bytes32 constant CREDIT_TOKEN_MINTER_ROLE = keccak256(
    "CREDIT_TOKEN_MINTER_ROLE"
);

/// @dev Role name for Credit tokens burner
bytes32 constant CREDIT_TOKEN_BURNER_ROLE = keccak256(
    "CREDIT_TOKEN_BURNER_ROLE"
);

/// @dev Role name for Dollar tokens minter
bytes32 constant DOLLAR_TOKEN_MINTER_ROLE = keccak256(
    "DOLLAR_TOKEN_MINTER_ROLE"
);

/// @dev Role name for Dollar tokens burner
bytes32 constant DOLLAR_TOKEN_BURNER_ROLE = keccak256(
    "DOLLAR_TOKEN_BURNER_ROLE"
);

/// @dev Role name for Dollar manager
bytes32 constant CURVE_DOLLAR_MANAGER_ROLE = keccak256(
    "CURVE_DOLLAR_MANAGER_ROLE"
);

/// @dev Role name for pauser
bytes32 constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

/// @dev Role name for Credit NFT manager
bytes32 constant CREDIT_NFT_MANAGER_ROLE = keccak256("CREDIT_NFT_MANAGER_ROLE");

/// @dev Role name for Staking manager
bytes32 constant STAKING_MANAGER_ROLE = keccak256("STAKING_MANAGER_ROLE");

/// @dev Role name for inventive manager
bytes32 constant INCENTIVE_MANAGER_ROLE = keccak256("INCENTIVE_MANAGER");

/// @dev Role name for Governance token manager
bytes32 constant GOVERNANCE_TOKEN_MANAGER_ROLE = keccak256(
    "GOVERNANCE_TOKEN_MANAGER_ROLE"
);

/// @dev Role name for Governance token manager
bytes32 constant DEFENDER_RELAYER_ROLE = keccak256("DEFENDER_RELAYER_ROLE");

/// @dev ETH pseudo address used to distinguish ERC20 tokens and ETH in `LibCollectableDust.sendDust()`
address constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

/// @dev 1 ETH
uint256 constant ONE = uint256(1 ether); // 3Crv has 18 decimals

/// @dev Accuracy used in `LibBondingCurve`
uint256 constant ACCURACY = 10e18;
/// @dev Max connector weight used in `LibBondingCurve`
uint32 constant MAX_WEIGHT = 1e6;

/// @dev keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
bytes32 constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

/// @dev Reentrancy constant
uint256 constant _NOT_ENTERED = 1;
/// @dev Reentrancy constant
uint256 constant _ENTERED = 2;

/// @dev Ubiquity pool price precision
uint256 constant UBIQUITY_POOL_PRICE_PRECISION = 1e6;
