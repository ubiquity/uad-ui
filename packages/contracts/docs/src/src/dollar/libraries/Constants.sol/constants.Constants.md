# Constants
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/libraries/Constants.sol)

### DEFAULT_ADMIN_ROLE
*Default admin role name*


```solidity
bytes32 constant DEFAULT_ADMIN_ROLE = 0x00;
```

### GOVERNANCE_TOKEN_MINTER_ROLE
*Role name for Governance tokens minter*


```solidity
bytes32 constant GOVERNANCE_TOKEN_MINTER_ROLE = keccak256("GOVERNANCE_TOKEN_MINTER_ROLE");
```

### GOVERNANCE_TOKEN_BURNER_ROLE
*Role name for Governance tokens burner*


```solidity
bytes32 constant GOVERNANCE_TOKEN_BURNER_ROLE = keccak256("GOVERNANCE_TOKEN_BURNER_ROLE");
```

### STAKING_SHARE_MINTER_ROLE
*Role name for staking share minter*


```solidity
bytes32 constant STAKING_SHARE_MINTER_ROLE = keccak256("STAKING_SHARE_MINTER_ROLE");
```

### STAKING_SHARE_BURNER_ROLE
*Role name for staking share burner*


```solidity
bytes32 constant STAKING_SHARE_BURNER_ROLE = keccak256("STAKING_SHARE_BURNER_ROLE");
```

### CREDIT_TOKEN_MINTER_ROLE
*Role name for Credit tokens minter*


```solidity
bytes32 constant CREDIT_TOKEN_MINTER_ROLE = keccak256("CREDIT_TOKEN_MINTER_ROLE");
```

### CREDIT_TOKEN_BURNER_ROLE
*Role name for Credit tokens burner*


```solidity
bytes32 constant CREDIT_TOKEN_BURNER_ROLE = keccak256("CREDIT_TOKEN_BURNER_ROLE");
```

### DOLLAR_TOKEN_MINTER_ROLE
*Role name for Dollar tokens minter*


```solidity
bytes32 constant DOLLAR_TOKEN_MINTER_ROLE = keccak256("DOLLAR_TOKEN_MINTER_ROLE");
```

### DOLLAR_TOKEN_BURNER_ROLE
*Role name for Dollar tokens burner*


```solidity
bytes32 constant DOLLAR_TOKEN_BURNER_ROLE = keccak256("DOLLAR_TOKEN_BURNER_ROLE");
```

### CURVE_DOLLAR_MANAGER_ROLE
*Role name for Dollar manager*


```solidity
bytes32 constant CURVE_DOLLAR_MANAGER_ROLE = keccak256("CURVE_DOLLAR_MANAGER_ROLE");
```

### PAUSER_ROLE
*Role name for pauser*


```solidity
bytes32 constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
```

### CREDIT_NFT_MANAGER_ROLE
*Role name for Credit NFT manager*


```solidity
bytes32 constant CREDIT_NFT_MANAGER_ROLE = keccak256("CREDIT_NFT_MANAGER_ROLE");
```

### STAKING_MANAGER_ROLE
*Role name for Staking manager*


```solidity
bytes32 constant STAKING_MANAGER_ROLE = keccak256("STAKING_MANAGER_ROLE");
```

### INCENTIVE_MANAGER_ROLE
*Role name for inventive manager*


```solidity
bytes32 constant INCENTIVE_MANAGER_ROLE = keccak256("INCENTIVE_MANAGER");
```

### GOVERNANCE_TOKEN_MANAGER_ROLE
*Role name for Governance token manager*


```solidity
bytes32 constant GOVERNANCE_TOKEN_MANAGER_ROLE = keccak256("GOVERNANCE_TOKEN_MANAGER_ROLE");
```

### ETH_ADDRESS
*ETH pseudo address used to distinguish ERC20 tokens and ETH in `LibCollectableDust.sendDust()`*


```solidity
address constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
```

### ONE
*1 ETH*


```solidity
uint256 constant ONE = uint256(1 ether);
```

### ACCURACY
*Accuracy used in `LibBondingCurve`*


```solidity
uint256 constant ACCURACY = 10e18;
```

### MAX_WEIGHT
*Max connector weight used in `LibBondingCurve`*


```solidity
uint32 constant MAX_WEIGHT = 1e6;
```

### PERMIT_TYPEHASH
*keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");*


```solidity
bytes32 constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
```

### _NOT_ENTERED
*Reentrancy constant*


```solidity
uint256 constant _NOT_ENTERED = 1;
```

### _ENTERED
*Reentrancy constant*


```solidity
uint256 constant _ENTERED = 2;
```

### UBIQUITY_POOL_PRICE_PRECISION
*Ubiquity pool price precision*


```solidity
uint256 constant UBIQUITY_POOL_PRICE_PRECISION = 1e6;
```

