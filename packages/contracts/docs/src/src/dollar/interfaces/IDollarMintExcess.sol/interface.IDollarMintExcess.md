# IDollarMintExcess
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/386de2abb8d1171ab47c0b149dede7c48631259f/src/dollar/interfaces/IDollarMintExcess.sol)

Interface for distributing excess Dollars when `mintClaimableDollars()` is called

Excess Dollars are distributed this way:
- 50% goes to the treasury address
- 10% goes for burning Dollar-Governance LP tokens in a DEX pool
- 40% goes to the Staking contract

Example:
1. 1000 Dollars should be distributed
2. 50% (500 Dollars) goes to the `AppStorage.treasuryAddress`
3. 10% (100 Dollars) goes for burning Dollar-Governance LP tokens:
- Half of 10% Dollars are swapped for Governance tokens on a DEX
- Governance tokens and half of 10% tokens are added as a liquidity to the Dollar-Governance DEX pool
- Dollar-Governance LP tokens are transferred to 0 address (i.e. burning LP tokens)
4. 40% (400 Dollars) goes to the Staking contract:
- Swap Dollars for 3CRV LP tokens in the Curve's Dollar-3CRV MetaPool
- Add 3CRV LP tokens to the Curve Dollar-3CRV MetaPool
- Transfer Dollar-3CRV LP tokens to the Staking contract


## Functions
### distributeDollars

Distributes excess Dollars:
- 50% goes to the treasury address
- 10% goes for burning Dollar-Governance LP tokens in a DEX pool
- 40% goes to the Staking contract


```solidity
function distributeDollars() external;
```

