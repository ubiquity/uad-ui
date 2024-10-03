# Modifiers
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/libraries/LibAppStorage.sol)

Contract includes modifiers shared across all protocol's contracts


## State Variables
### store
Shared struct used as a storage across all protocol's contracts


```solidity
AppStorage internal store;
```


## Functions
### nonReentrant

Prevents a contract from calling itself, directly or indirectly.
Calling a `nonReentrant` function from another `nonReentrant`
function is not supported. It is possible to prevent this from happening
by making the `nonReentrant` function external, and making it call a
`private` function that does the actual work.

*Works identically to OZ's nonReentrant.*

*Used to avoid state storage collision within diamond.*


```solidity
modifier nonReentrant();
```

### onlyOwner

Checks that method is called by a contract owner


```solidity
modifier onlyOwner();
```

### onlyCreditNftManager

Checks that method is called by address with the `CREDIT_NFT_MANAGER_ROLE` role


```solidity
modifier onlyCreditNftManager();
```

### onlyAdmin

Checks that method is called by address with the `DEFAULT_ADMIN_ROLE` role


```solidity
modifier onlyAdmin();
```

### onlyMinter

Checks that method is called by address with the `GOVERNANCE_TOKEN_MINTER_ROLE` role


```solidity
modifier onlyMinter();
```

### onlyBurner

Checks that method is called by address with the `GOVERNANCE_TOKEN_BURNER_ROLE` role


```solidity
modifier onlyBurner();
```

### whenNotPaused

Modifier to make a function callable only when the contract is not paused


```solidity
modifier whenNotPaused();
```

### whenPaused

Modifier to make a function callable only when the contract is paused


```solidity
modifier whenPaused();
```

### onlyStakingManager

Checks that method is called by address with the `STAKING_MANAGER_ROLE` role


```solidity
modifier onlyStakingManager();
```

### onlyPauser

Checks that method is called by address with the `PAUSER_ROLE` role


```solidity
modifier onlyPauser();
```

### onlyTokenManager

Checks that method is called by address with the `GOVERNANCE_TOKEN_MANAGER_ROLE` role


```solidity
modifier onlyTokenManager();
```

### onlyIncentiveAdmin

Checks that method is called by address with the `INCENTIVE_MANAGER_ROLE` role


```solidity
modifier onlyIncentiveAdmin();
```

### onlyDollarManager

Checks that method is called by address with the `CURVE_DOLLAR_MANAGER_ROLE` role


```solidity
modifier onlyDollarManager();
```

### _initReentrancyGuard

Initializes reentrancy guard on contract deployment


```solidity
function _initReentrancyGuard() internal;
```

