# LibUbiquityPool
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/libraries/LibUbiquityPool.sol)

Ubiquity pool library

Allows users to:
- deposit collateral in exchange for Ubiquity Dollars
- redeem Ubiquity Dollars in exchange for the earlier provided collateral


## State Variables
### UBIQUITY_POOL_STORAGE_POSITION
Storage slot used to store data for this library


```solidity
bytes32 constant UBIQUITY_POOL_STORAGE_POSITION =
    bytes32(uint256(keccak256("ubiquity.contracts.ubiquity.pool.storage")) - 1) & ~bytes32(uint256(0xff));
```


## Functions
### ubiquityPoolStorage

Returns struct used as a storage for this library


```solidity
function ubiquityPoolStorage() internal pure returns (UbiquityPoolStorage storage uPoolStorage);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`uPoolStorage`|`UbiquityPoolStorage`|Struct used as a storage|


### collateralEnabled

Checks whether collateral token is enabled (i.e. mintable and redeemable)


```solidity
modifier collateralEnabled(uint256 collateralIndex);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralIndex`|`uint256`|Collateral token index|


### onlyAmoMinter

Checks whether a caller is the AMO minter address


```solidity
modifier onlyAmoMinter();
```

### allCollaterals

Returns all collateral addresses


```solidity
function allCollaterals() internal view returns (address[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|All collateral addresses|


### collateralExists

Check if collateral token with given address already exists


```solidity
function collateralExists(address collateralAddress) internal view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralAddress`|`address`|The collateral token address to check|


### collateralInformation

Returns collateral information


```solidity
function collateralInformation(address collateralAddress)
    internal
    view
    returns (CollateralInformation memory returnData);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralAddress`|`address`|Address of the collateral token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`returnData`|`CollateralInformation`|Collateral info|


### collateralRatio

Returns current collateral ratio


```solidity
function collateralRatio() internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Collateral ratio|


### collateralUsdBalance

Returns USD value of all collateral tokens held in the pool, in E18


```solidity
function collateralUsdBalance() internal view returns (uint256 balanceTally);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`balanceTally`|`uint256`|USD value of all collateral tokens|


### ethUsdPriceFeedInformation

Returns chainlink price feed information for ETH/USD pair


```solidity
function ethUsdPriceFeedInformation() internal view returns (address, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Price feed address and staleness threshold in seconds|
|`<none>`|`uint256`||


### freeCollateralBalance

Returns free collateral balance (i.e. that can be borrowed by AMO minters)


```solidity
function freeCollateralBalance(uint256 collateralIndex) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralIndex`|`uint256`|collateral token index|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of free collateral|


### getDollarInCollateral

Returns Dollar value in collateral tokens


```solidity
function getDollarInCollateral(uint256 collateralIndex, uint256 dollarAmount) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralIndex`|`uint256`|collateral token index|
|`dollarAmount`|`uint256`|Amount of Dollars|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Value in collateral tokens|


### getDollarPriceUsd

Returns Ubiquity Dollar token USD price (1e6 precision) from Curve plain pool (Stable coin, Ubiquity Dollar)
How it works:
1. Fetch Stable/USD quote from chainlink
2. Fetch Dollar/Stable quote from Curve's plain pool
3. Calculate Dollar token price in USD


```solidity
function getDollarPriceUsd() internal view returns (uint256 dollarPriceUsd);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`dollarPriceUsd`|`uint256`|USD price of Ubiquity Dollar|


### getGovernancePriceUsd

Returns Governance token price in USD (6 decimals precision)

*How it works:
1. Fetch ETH/USD price from chainlink oracle
2. Fetch Governance/ETH price from Curve's oracle
3. Calculate Governance token price in USD*


```solidity
function getGovernancePriceUsd() internal view returns (uint256 governancePriceUsd);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`governancePriceUsd`|`uint256`|Governance token price in USD|


### getRedeemCollateralBalance

Returns user's balance available for redemption


```solidity
function getRedeemCollateralBalance(address userAddress, uint256 collateralIndex) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`userAddress`|`address`|User address|
|`collateralIndex`|`uint256`|Collateral token index|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|User's balance available for redemption|


### getRedeemGovernanceBalance

Returns user's Governance tokens balance available for redemption


```solidity
function getRedeemGovernanceBalance(address userAddress) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`userAddress`|`address`|User address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|User's Governance tokens balance available for redemption|


### governanceEthPoolAddress

Returns pool address for Governance/ETH pair


```solidity
function governanceEthPoolAddress() internal view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Pool address|


### stableUsdPriceFeedInformation

Returns chainlink price feed information for stable/USD pair

*Here stable coin refers to the 1st coin in the Curve's stable/Dollar plain pool*


```solidity
function stableUsdPriceFeedInformation() internal view returns (address, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Price feed address and staleness threshold in seconds|
|`<none>`|`uint256`||


### mintDollar

Mints Dollars in exchange for collateral tokens


```solidity
function mintDollar(
    uint256 collateralIndex,
    uint256 dollarAmount,
    uint256 dollarOutMin,
    uint256 maxCollateralIn,
    uint256 maxGovernanceIn,
    bool isOneToOne
)
    internal
    collateralEnabled(collateralIndex)
    returns (uint256 totalDollarMint, uint256 collateralNeeded, uint256 governanceNeeded);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralIndex`|`uint256`|Collateral token index|
|`dollarAmount`|`uint256`|Amount of dollars to mint|
|`dollarOutMin`|`uint256`|Min amount of dollars to mint (slippage protection)|
|`maxCollateralIn`|`uint256`|Max amount of collateral to send (slippage protection)|
|`maxGovernanceIn`|`uint256`|Max amount of Governance tokens to send (slippage protection)|
|`isOneToOne`|`bool`|Force providing only collateral without Governance tokens|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`totalDollarMint`|`uint256`|Amount of Dollars minted|
|`collateralNeeded`|`uint256`|Amount of collateral sent to the pool|
|`governanceNeeded`|`uint256`|Amount of Governance tokens burnt from sender|


### redeemDollar

Burns redeemable Ubiquity Dollars and sends back 1 USD of collateral token for every 1 Ubiquity Dollar burned

*Redeem process is split in two steps:*

*1. `redeemDollar()`*

*2. `collectRedemption()`*

*This is done in order to prevent someone using a flash loan of a collateral token to mint, redeem, and collect in a single transaction/block*


```solidity
function redeemDollar(uint256 collateralIndex, uint256 dollarAmount, uint256 governanceOutMin, uint256 collateralOutMin)
    internal
    collateralEnabled(collateralIndex)
    returns (uint256 collateralOut, uint256 governanceOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralIndex`|`uint256`|Collateral token index being withdrawn|
|`dollarAmount`|`uint256`|Amount of Ubiquity Dollars being burned|
|`governanceOutMin`|`uint256`|Minimum amount of Governance tokens that'll be withdrawn, used to set acceptable slippage|
|`collateralOutMin`|`uint256`|Minimum amount of collateral tokens that'll be withdrawn, used to set acceptable slippage|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`collateralOut`|`uint256`|Amount of collateral tokens ready for redemption|
|`governanceOut`|`uint256`||


### collectRedemption

Used to collect collateral and Governance tokens after redeeming/burning Ubiquity Dollars

*Redeem process is split in two steps:*

*1. `redeemDollar()`*

*2. `collectRedemption()`*

*This is done in order to prevent someone using a flash loan of a collateral token to mint, redeem, and collect in a single transaction/block*


```solidity
function collectRedemption(uint256 collateralIndex)
    internal
    collateralEnabled(collateralIndex)
    returns (uint256 governanceAmount, uint256 collateralAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralIndex`|`uint256`|Collateral token index being collected|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`governanceAmount`|`uint256`|Amount of Governance tokens redeemed|
|`collateralAmount`|`uint256`|Amount of collateral tokens redeemed|


### updateChainLinkCollateralPrice

Updates collateral token price in USD from ChainLink price feed


```solidity
function updateChainLinkCollateralPrice(uint256 collateralIndex) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralIndex`|`uint256`|Collateral token index|


### amoMinterBorrow

Allows AMO minters to borrow collateral to make yield in external
protocols like Compound, Curve, erc...

*Bypasses the gassy mint->redeem cycle for AMOs to borrow collateral*


```solidity
function amoMinterBorrow(uint256 collateralAmount) internal onlyAmoMinter;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralAmount`|`uint256`|Amount of collateral to borrow|


### addAmoMinter

Adds a new AMO minter


```solidity
function addAmoMinter(address amoMinterAddress) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amoMinterAddress`|`address`|AMO minter address|


### addCollateralToken

Adds a new collateral token


```solidity
function addCollateralToken(address collateralAddress, address chainLinkPriceFeedAddress, uint256 poolCeiling)
    internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralAddress`|`address`|Collateral token address|
|`chainLinkPriceFeedAddress`|`address`|Chainlink's price feed address|
|`poolCeiling`|`uint256`|Max amount of available tokens for collateral|


### removeAmoMinter

Removes AMO minter


```solidity
function removeAmoMinter(address amoMinterAddress) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amoMinterAddress`|`address`|AMO minter address to remove|


### setCollateralChainLinkPriceFeed

Sets collateral ChainLink price feed params


```solidity
function setCollateralChainLinkPriceFeed(
    address collateralAddress,
    address chainLinkPriceFeedAddress,
    uint256 stalenessThreshold
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralAddress`|`address`|Collateral token address|
|`chainLinkPriceFeedAddress`|`address`|ChainLink price feed address|
|`stalenessThreshold`|`uint256`|Threshold in seconds when chainlink answer should be considered stale|


### setCollateralRatio

Sets collateral ratio

*How much collateral/governance tokens user should provide/get to mint/redeem Dollar tokens, 1e6 precision.*

*Collateral ratio is capped to 100%.*

*Example (1_000_000 = 100%):
- Mint: user provides 1 collateral token to get 1 Dollar
- Redeem: user gets 1 collateral token for 1 Dollar*

*Example (900_000 = 90%):
- Mint: user provides 0.9 collateral token and 0.1 Governance token to get 1 Dollar
- Redeem: user gets 0.9 collateral token and 0.1 Governance token for 1 Dollar*


```solidity
function setCollateralRatio(uint256 newCollateralRatio) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newCollateralRatio`|`uint256`|New collateral ratio|


### setEthUsdChainLinkPriceFeed

Sets chainlink params for ETH/USD price feed


```solidity
function setEthUsdChainLinkPriceFeed(address newPriceFeedAddress, uint256 newStalenessThreshold) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newPriceFeedAddress`|`address`|New chainlink price feed address for ETH/USD pair|
|`newStalenessThreshold`|`uint256`|New threshold in seconds when chainlink's ETH/USD price feed answer should be considered stale|


### setFees

Sets mint and redeem fees, 1_000_000 = 100%


```solidity
function setFees(uint256 collateralIndex, uint256 newMintFee, uint256 newRedeemFee) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralIndex`|`uint256`|Collateral token index|
|`newMintFee`|`uint256`|New mint fee|
|`newRedeemFee`|`uint256`|New redeem fee|


### setGovernanceEthPoolAddress

Sets a new pool address for Governance/ETH pair

*Based on Curve's CurveTwocryptoOptimized contract. Used for fetching Governance token USD price.
How it works:
1. Fetch Governance/ETH price from CurveTwocryptoOptimized's built-in oracle
2. Fetch ETH/USD price from chainlink feed
3. Calculate Governance token price in USD*


```solidity
function setGovernanceEthPoolAddress(address newGovernanceEthPoolAddress) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newGovernanceEthPoolAddress`|`address`|New pool address for Governance/ETH pair|


### setPoolCeiling

Sets max amount of collateral for a particular collateral token


```solidity
function setPoolCeiling(uint256 collateralIndex, uint256 newCeiling) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralIndex`|`uint256`|Collateral token index|
|`newCeiling`|`uint256`|Max amount of collateral|


### setPriceThresholds

Sets mint and redeem price thresholds, 1_000_000 = $1.00


```solidity
function setPriceThresholds(uint256 newMintPriceThreshold, uint256 newRedeemPriceThreshold) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newMintPriceThreshold`|`uint256`|New mint price threshold|
|`newRedeemPriceThreshold`|`uint256`|New redeem price threshold|


### setRedemptionDelayBlocks

Sets a redemption delay in blocks

*Redeeming is split in 2 actions:*

*1. `redeemDollar()`*

*2. `collectRedemption()`*

*`newRedemptionDelayBlocks` sets number of blocks that should be mined after which user can call `collectRedemption()`*


```solidity
function setRedemptionDelayBlocks(uint256 newRedemptionDelayBlocks) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newRedemptionDelayBlocks`|`uint256`|Redemption delay in blocks|


### setStableUsdChainLinkPriceFeed

Sets chainlink params for stable/USD price feed

*Here stable coin refers to the 1st coin in the Curve's stable/Dollar plain pool*


```solidity
function setStableUsdChainLinkPriceFeed(address newPriceFeedAddress, uint256 newStalenessThreshold) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newPriceFeedAddress`|`address`|New chainlink price feed address for stable/USD pair|
|`newStalenessThreshold`|`uint256`|New threshold in seconds when chainlink's stable/USD price feed answer should be considered stale|


### toggleCollateral

Toggles (i.e. enables/disables) a particular collateral token


```solidity
function toggleCollateral(uint256 collateralIndex) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralIndex`|`uint256`|Collateral token index|


### toggleMintRedeemBorrow

Toggles pause for mint/redeem/borrow methods


```solidity
function toggleMintRedeemBorrow(uint256 collateralIndex, uint8 toggleIndex) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralIndex`|`uint256`|Collateral token index|
|`toggleIndex`|`uint8`|Method index. 0 - toggle mint pause, 1 - toggle redeem pause, 2 - toggle borrow by AMO pause|


## Events
### AmoMinterAdded
Emitted when new AMO minter is added


```solidity
event AmoMinterAdded(address amoMinterAddress);
```

### AmoMinterRemoved
Emitted when AMO minter is removed


```solidity
event AmoMinterRemoved(address amoMinterAddress);
```

### CollateralPriceFeedSet
Emitted on setting a chainlink's collateral price feed params


```solidity
event CollateralPriceFeedSet(uint256 collateralIndex, address priceFeedAddress, uint256 stalenessThreshold);
```

### CollateralPriceSet
Emitted on setting a collateral price


```solidity
event CollateralPriceSet(uint256 collateralIndex, uint256 newPrice);
```

### CollateralRatioSet
Emitted on setting a collateral ratio


```solidity
event CollateralRatioSet(uint256 newCollateralRatio);
```

### CollateralToggled
Emitted on enabling/disabling a particular collateral token


```solidity
event CollateralToggled(uint256 collateralIndex, bool newState);
```

### EthUsdPriceFeedSet
Emitted on setting chainlink's price feed for ETH/USD pair


```solidity
event EthUsdPriceFeedSet(address newPriceFeedAddress, uint256 newStalenessThreshold);
```

### FeesSet
Emitted when fees are updated


```solidity
event FeesSet(uint256 collateralIndex, uint256 newMintFee, uint256 newRedeemFee);
```

### GovernanceEthPoolSet
Emitted on setting a pool for Governance/ETH pair


```solidity
event GovernanceEthPoolSet(address newGovernanceEthPoolAddress);
```

### MintRedeemBorrowToggled
Emitted on toggling pause for mint/redeem/borrow


```solidity
event MintRedeemBorrowToggled(uint256 collateralIndex, uint8 toggleIndex);
```

### PoolCeilingSet
Emitted when new pool ceiling (i.e. max amount of collateral) is set


```solidity
event PoolCeilingSet(uint256 collateralIndex, uint256 newCeiling);
```

### PriceThresholdsSet
Emitted when mint and redeem price thresholds are updated (1_000_000 = $1.00)


```solidity
event PriceThresholdsSet(uint256 newMintPriceThreshold, uint256 newRedeemPriceThreshold);
```

### RedemptionDelayBlocksSet
Emitted when a new redemption delay in blocks is set


```solidity
event RedemptionDelayBlocksSet(uint256 redemptionDelayBlocks);
```

### StableUsdPriceFeedSet
Emitted on setting chainlink's price feed for stable/USD pair


```solidity
event StableUsdPriceFeedSet(address newPriceFeedAddress, uint256 newStalenessThreshold);
```

## Structs
### UbiquityPoolStorage
Struct used as a storage for this library


```solidity
struct UbiquityPoolStorage {
    mapping(address amoMinter => bool isEnabled) isAmoMinterEnabled;
    address[] collateralAddresses;
    mapping(address collateralAddress => uint256 collateralIndex) collateralIndex;
    address[] collateralPriceFeedAddresses;
    uint256[] collateralPriceFeedStalenessThresholds;
    uint256[] collateralPrices;
    uint256 collateralRatio;
    string[] collateralSymbols;
    mapping(address collateralAddress => bool isEnabled) isCollateralEnabled;
    uint256[] missingDecimals;
    uint256[] poolCeilings;
    mapping(address => uint256) lastRedeemedBlock;
    uint256 mintPriceThreshold;
    uint256 redeemPriceThreshold;
    mapping(address user => mapping(uint256 collateralIndex => uint256 amount)) redeemCollateralBalances;
    mapping(address user => uint256 amount) redeemGovernanceBalances;
    uint256 redemptionDelayBlocks;
    uint256[] unclaimedPoolCollateral;
    uint256 unclaimedPoolGovernance;
    uint256[] mintingFee;
    uint256[] redemptionFee;
    bool[] isBorrowPaused;
    bool[] isMintPaused;
    bool[] isRedeemPaused;
    address ethUsdPriceFeedAddress;
    uint256 ethUsdPriceFeedStalenessThreshold;
    address governanceEthPoolAddress;
    address stableUsdPriceFeedAddress;
    uint256 stableUsdPriceFeedStalenessThreshold;
}
```

### CollateralInformation
Struct used for detailed collateral information


```solidity
struct CollateralInformation {
    uint256 index;
    string symbol;
    address collateralAddress;
    address collateralPriceFeedAddress;
    uint256 collateralPriceFeedStalenessThreshold;
    bool isEnabled;
    uint256 missingDecimals;
    uint256 price;
    uint256 poolCeiling;
    bool isMintPaused;
    bool isRedeemPaused;
    bool isBorrowPaused;
    uint256 mintingFee;
    uint256 redemptionFee;
}
```

