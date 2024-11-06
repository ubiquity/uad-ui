[![Build & Test](https://github.com/ubiquity/ubiquity-dollar/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/ubiquity/ubiquity-dollar/actions/workflows/build-and-test.yml)
[![Coverage Status](https://coveralls.io/repos/github/ubiquity/ubiquity-dollar/badge.svg?branch=development&service=github)](https://coveralls.io/github/ubiquity/ubiquity-dollar?branch=development)
# Ubiquity Dollar
Introducing the flagship product of [Ubiquity DAO](https://ubq.fi/). The Ubiquity Dollar (uAD) is a collateralized stablecoin.
- The deployed smart contracts can be found in the [docs](https://dao.ubq.fi/smart-contracts).
- The source code for those are archived [here](https://github.com/ubiquity/uad-contracts).

![Ubiquity Dollar Logo](https://user-images.githubusercontent.com/4975670/153777249-527395c0-0c52-4731-8b0a-77b7885fafda.png)
## Contributing
- We welcome everybody to participate in improving the codebase and provide feedback on opened issues.
- We offer financial incentives for solved issues.
- Learn how to contribute via the DevPool [here](https://dao.ubq.fi/devpool).
## Installation
### Requirements:
- NodeJS Version >=18
- Yarn
- We use [Foundry](https://github.com/foundry-rs/foundry), check their [docs](https://book.getfoundry.sh/). Please follow their installation guide for your OS before proceeding.

### Development Setup

```sh
#!/bin/bash

git clone https://github.com/ubiquity/ubiquity-dollar.git
cd ubiquity-dollar
yarn # fetch dependencies
yarn build:all # builds the smart contracts and user interface

# Optional
yarn build:dapp # to only build the UI useful for debugging
yarn build:contracts # to only build the Smart Contracts

yarn start # starts the user interface and daemonize'd to continue to run tests in the background
yarn test:all # We run all the tests!
```

## Running workspace specific/individual commands
Using yarn workspaces, you can invoke scripts for each workspace individually.
```sh
# SCRIPT_NAME=XXX

yarn workspace @ubiquity/contracts $SCRIPT_NAME
yarn workspace @ubiquity/dapp $SCRIPT_NAME

# Some commands...

yarn workspace @ubiquity/contracts build # Build smart contracts
yarn workspace @ubiquity/contracts test # Run the smart contract unit tests

yarn workspace @ubiquity/dapp build # Build the user interface
yarn workspace @ubiquity/dapp start # Run the web application at http://localhost:3000

# check https://yarnpkg.com/features/workspaces for more yarn workspaces flexixble use cases

```
## Committing Code/Sending PRs

1. We [automatically enforce](https://github.com/conventional-changelog/commitlint) the [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) format for commit messages.

> The Conventional Commits specification is a lightweight convention on top of commit messages. It provides an easy set of rules for creating an explicit commit history; which makes it easier to write automated tools on top of.

2. We use [prettier](https://github.com/prettier/prettier), [eslint](https://github.com/eslint/eslint) and [cspell](https://github.com/streetsidesoftware/cspell) on [staged files](https://github.com/okonet/lint-staged) in order to enforce a uniform code style. Please do not circumvent these rules.

3. We require all PRs to meet the issues expectation and/or to follow the discussions accordingly and implement all necessary changes and feedback by reviewers.

4. We run [CI jobs](https://github.com/ubiquity/ubiquity-dollar/actions) all CI jobs must pass before committing/merging a PR with no exceptions (usually a few exceptions while the PR it's getting reviewed and the maintainers highlight a job run that may skip)

5. We run Solhint to enforce a pre-set selected number of rules for code quality/style on Smart Contracts

### Network Settings
| Network | Chain ID | RPC Endpoint                  | Comment |
|---------|----------|-------------------------------|---------|
| `mainnet` | `1`        | `https://rpc.ankr.com/eth` | Public Mainnet Gateway    |
| `anvil`   | `31337`    | `http://127.0.0.1:8545`         | Used for local development     |
| `sepolia` | `11155111` | `https://ethereum-sepolia.publicnode.com` |Use any public available RPC for Sepolia testing |

## Deploying Contracts (Ubiquity Dollar Core)

You need to create a new `.env` file and set all necessary env variables, example:

```sh
# Admin private key (grants access to restricted contracts methods).
# By default set to the private key from the 0x70997970c51812dc3a010c7d01b50e0d17dc79c8 address
# which is the 2nd address derived from test mnemonic "test test test test test test test test test test test junk".
ADMIN_PRIVATE_KEY="0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"

# Collateral token address (used in UbiquityPoolFacet, allows users to mint/redeem Dollars in exchange for collateral token).
# By default set to LUSD address in ethereum mainnet.
# - mainnet: 0x5f98805A4E8be255a32880FDeC7F6728C6568bA0 (LUSD)
# - testnet/anvil: deploys collateral ERC20 token from scratch
COLLATERAL_TOKEN_ADDRESS="0x5f98805A4E8be255a32880FDeC7F6728C6568bA0"

# Collateral token price feed address from chainlink.
# By default set to LUSD/USD price feed deployed on ethereum mainnet.
# This price feed is used in 2 cases:
# 1) To calculate collateral price in USD
# 2) To calculate Dollar price in USD
# Since collateral token (LUSD) is the same one used in Curve's plain pool (LUSD-Dollar)
# we share the same price feed in:
# 1) `LibUbiquityPool.setCollateralChainLinkPriceFeed()` (to calculate collateral price in USD)
# 2) `LibUbiquityPool.setStableUsdChainLinkPriceFeed()` (to calculate Dollar price in USD)
# - mainnet: uses already deployed LUSD/USD chainlink price feed
# - testnet/anvil: deploys LUSD/USD chainlink price feed from scratch
COLLATERAL_TOKEN_CHAINLINK_PRICE_FEED_ADDRESS="0x3D7aE7E594f2f2091Ad8798313450130d0Aba3a0"

# Curve's Governance/WETH pool address.
# Used to fetch Governance/ETH price from built-in oracle.
# By default set to already deployed (production ready) Governance/WETH pool address.
# - mainnet: uses already deployed Governance/ETH pool address
# - testnet/anvil: deploys Governance/WETH pool from scratch
CURVE_GOVERNANCE_WETH_POOL_ADDRESS="0xaCDc85AFCD8B83Eb171AFFCbe29FaD204F6ae45C"

# Chainlink price feed address for ETH/USD pair.
# Used to calculate Governance token price in USD.
# By default set to ETH/USD price feed deployed on ethereum mainnet.
# - mainnet: uses already deployed ETH/USD chainlink price feed
# - testnet/anvil: deploys ETH/USD chainlink price feed from scratch
ETH_USD_CHAINLINK_PRICE_FEED_ADDRESS="0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419"

# Dollar amount in wei minted initially to owner to provide liquidity to the Curve LUSD-Dollar plain pool
# By default set to 25k Dollar tokens
INITIAL_DOLLAR_MINT_AMOUNT_WEI="25000000000000000000000"

# Owner private key (grants access to updating Diamond facets and setting TWAP oracle address).
# By default set to the private key from the 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266 address
# which is the 1st address derived from test mnemonic "test test test test test test test test test test test junk".
OWNER_PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"

# RPC URL (used in contract migrations)
# - anvil: http://127.0.0.1:8545
# - testnet: https://sepolia.gateway.tenderly.co
# - mainnet: https://mainnet.gateway.tenderly.co
RPC_URL="http://127.0.0.1:8545"
```

We provide an `.env.example` file pre-set with recommend testing environment variables but you are free to modify or experiment with different values on your local branch.

Then in two separate terminals run the following commands:

```sh
# starts the anvil forked mainnet/testnet network (depends on your .env config)
yarn workspace @ubiquity/contracts start:anvil

# Optional
yarn start:anvil # same as above but shorter
```

```sh
# deploys the contracts to the anvil testnet or your desired network

yarn workspace @ubiquity/contracts deploy:development

# Optional
yarn deploy:development # same as above
```

If successful it will output the accounts generated from the test mnemonic (`test test test test test test test test test test test junk`) and the port it's listening on.

## Our Official Deployments

### Ethereum Mainnet

| Contract                              | Address |
|---------------------------------------|---------|
| Proxy Yield Aggregator Beta           | [0x580f30316562448f4642bd33fb44f2ca1bc0cc1e](https://etherscan.io/address/0x580f30316562448f4642bd33fb44f2ca1bc0cc1e) |
| Bonding.sol                           | [0x831e3674Abc73d7A3e9d8a9400AF2301c32cEF0C](https://etherscan.io/address/0x831e3674Abc73d7A3e9d8a9400AF2301c32cEF0C) |
| BondingV2.sol                         | [0xc251ecd9f1bd5230823f9a0f99a44a87ddd4ca38](https://etherscan.io/address/0xc251ecd9f1bd5230823f9a0f99a44a87ddd4ca38) |
| BondingFormulas.sol                   | [0x190474f062d05fba6d46a4d358c4d031075df2b4](https://etherscan.io/address/0x190474f062d05fba6d46a4d358c4d031075df2b4) |
| BondingShare.sol                      | [0x0013B6033dd999676Dc547CEeCEA29f781D8Db17](https://etherscan.io/address/0x0013B6033dd999676Dc547CEeCEA29f781D8Db17) |
| BondingShareV2.sol                    | [0x2da07859613c14f6f05c97efe37b9b4f212b5ef5](https://etherscan.io/address/0x2da07859613c14f6f05c97efe37b9b4f212b5ef5) |
| CouponsForDollarsCalculator.sol       | [0x4F3dF4c1e22209d623ab55923109112f1E2B17DE](https://etherscan.io/address/0x4F3dF4c1e22209d623ab55923109112f1E2B17DE) |
| CurveUADIncentive.sol                 | [0x86965cdB680350C5de2Fd8D28055DecDDD52745E](https://etherscan.io/address/0x86965cdB680350C5de2Fd8D28055DecDDD52745E) |
| DEBTCoupon.sol                        | [0xcEFAF85110536eC6F78B0B71624BfA584B6fABa1](https://etherscan.io/address/0xcEFAF85110536eC6F78B0B71624BfA584B6fABa1) |
| DEBTCouponManager.sol                 | [0x432120Ad63779897A424f7905BA000dF38A74554](https://etherscan.io/address/0x432120Ad63779897A424f7905BA000dF38A74554) |
| DollarMintingCalculator.sol           | [0xab840faA6A5eF68D8D32370EBC297f4DdC9F870F](https://etherscan.io/address/0xab840faA6A5eF68D8D32370EBC297f4DdC9F870F) |
| ExcessDollarsDistributor.sol          | [0x25d2b980E406bE97237A06Bca636AeD607661Dfa](https://etherscan.io/address/0x25d2b980E406bE97237A06Bca636AeD607661Dfa) |
| MasterChef.sol                        | [0x8fFCf9899738e4633A721904609ffCa0a2C44f3D](https://etherscan.io/address/0x8fFCf9899738e4633A721904609ffCa0a2C44f3D) |
| MasterChefV2.sol                      | [0xb8ec70d24306ecef9d4aaf9986dcb1da5736a997](https://etherscan.io/address/0xb8ec70d24306ecef9d4aaf9986dcb1da5736a997) |
| MasterChefV2.1.sol                    | [0xdae807071b5ac7b6a2a343bead19929426dbc998](https://etherscan.io/address/0xdae807071b5ac7b6a2a343bead19929426dbc998) |
| SushiSwapPool.sol                     | [0x534ac94F198F1fef0aDC45227A2185C7cE8d75dC](https://etherscan.io/address/0x534ac94F198F1fef0aDC45227A2185C7cE8d75dC) |
| TWAPOracle.sol                        | [0x7944d5b8f9668AfB1e648a61e54DEa8DE734c1d1](https://etherscan.io/address/0x7944d5b8f9668AfB1e648a61e54DEa8DE734c1d1) |
| UARForDollarsCalculator.sol           | [0x75d6F33BcF784504dA74e4aD60c677CD1fD3e2d5](https://etherscan.io/address/0x75d6F33BcF784504dA74e4aD60c677CD1fD3e2d5) |
| UbiquityAlgorithmicDollarManager.sol | [0x4DA97a8b831C345dBe6d16FF7432DF2b7b776d98](https://etherscan.io/address/0x4DA97a8b831C345dBe6d16FF7432DF2b7b776d98) |
| UbiquityAlgorithmicDollar.sol         | [0x0F644658510c95CB46955e55D7BA9DDa9E9fBEc6](https://etherscan.io/address/0x0F644658510c95CB46955e55D7BA9DDa9E9fBEc6) |
| UbiquityAutoRedeem.sol                | [0x5894cFEbFdEdBe61d01F20140f41c5c49AedAe97](https://etherscan.io/address/0x5894cFEbFdEdBe61d01F20140f41c5c49AedAe97) |
| UbiquityFormulas.sol                  | [0x54F528979A50FA8Fe99E0118EbbEE5fC8Ea802F7](https://etherscan.io/address/0x54F528979A50FA8Fe99E0118EbbEE5fC8Ea802F7) |
| UbiquityGovernance.sol                | [0x4e38D89362f7e5db0096CE44ebD021c3962aA9a0](https://etherscan.io/address/0x4e38D89362f7e5db0096CE44ebD021c3962aA9a0) |

### Gnosis Chain

| Contract                              | Address |
|---------------------------------------|---------|
| UbiquityAlgorithmicDollar.sol         | [0xc6ed4f520f6a4e4dc27273509239b7f8a68d2068](https://gnosisscan.io/address/0xc6ed4f520f6a4e4dc27273509239b7f8a68d2068) |

## Wiki

We have a [Wiki!](https://github.com/ubiquity/ubiquity-dollar/wiki) feel free to browse it as there is a lot of useful information about the whole repo

## Yarn Workspaces

The repo has been built as a [yarn workspace](https://yarnpkg.com/features/workspaces) monorepo.

<pre>
&lt;root&gt;
├── <a href="https://github.com/ubiquity/ubiquity-dollar/tree/development/packages">packages</a>
│   ├── <a href="https://github.com/ubiquity/ubiquity-dollar/tree/development/packages/contracts">contracts</a>: Smart contracts for Ubiquity Dollar and UbiquiStick
│   ├── <a href="https://github.com/ubiquity/ubiquity-dollar/tree/development/packages/dapp">dapp</a>: User interface
</pre>

## Codebase Diagram

[Interactive Version](https://mango-dune-07a8b7110.1.azurestaticapps.net/?repo=ubiquity%2Fubiquity-dollar)

### Smart Contracts

![Visualization of the smart contracts codebase](./utils/diagram-contracts.svg)

### User Interface

![Visualization of the user interface codebase](./utils/diagram-ui.svg)

---

### Audits

2024 - [Sherlock](https://github.com/ubiquity/ubiquity-dollar/blob/development/packages/contracts/audits/ubiquity-audit-report-sherlock.pdf)

Sine stabilitate nihil habemus.
