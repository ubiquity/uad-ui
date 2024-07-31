# UbiquityPoolFacet
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/facets/UbiquityPoolFacet.sol)

**Inherits:**
[IUbiquityPool](/src/dollar/interfaces/IUbiquityPool.sol/interface.IUbiquityPool.md), [Modifiers](/src/dollar/libraries/LibAppStorage.sol/contract.Modifiers.md)

Ubiquity pool facet

Allows users to:
- deposit collateral in exchange for Ubiquity Dollars
- redeem Ubiquity Dollars in exchange for the earlier provided collateral


## Functions
### allCollaterals

Returns all collateral addresses


```solidity
function allCollaterals() external view returns (address[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|All collateral addresses|


### collateralInformation

Returns collateral information


```solidity
function collateralInformation(address collateralAddress)
    external
    view
    returns (LibUbiquityPool.CollateralInformation memory returnData);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralAddress`|`address`|Address of the collateral token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`returnData`|`LibUbiquityPool.CollateralInformation`|Collateral info|


### collateralRatio

Returns current collateral ratio


```solidity
function collateralRatio() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Collateral ratio|


### collateralUsdBalance

Returns USD value of all collateral tokens held in the pool, in E18


```solidity
function collateralUsdBalance() external view returns (uint256 balanceTally);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`balanceTally`|`uint256`|USD value of all collateral tokens|


### ethUsdPriceFeedInformation

Returns chainlink price feed information for ETH/USD pair


```solidity
function ethUsdPriceFeedInformation() external view returns (address, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Price feed address and staleness threshold in seconds|
|`<none>`|`uint256`||


### freeCollateralBalance

Returns free collateral balance (i.e. that can be borrowed by AMO minters)


```solidity
function freeCollateralBalance(uint256 collateralIndex) external view returns (uint256);
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
function getDollarInCollateral(uint256 collateralIndex, uint256 dollarAmount) external view returns (uint256);
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

Returns Ubiquity Dollar token USD price (1e6 precision) from Curve Metapool (Ubiquity Dollar, Curve Tri-Pool LP)


```solidity
function getDollarPriceUsd() external view returns (uint256 dollarPriceUsd);
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
function getGovernancePriceUsd() external view returns (uint256 governancePriceUsd);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`governancePriceUsd`|`uint256`|Governance token price in USD|


### getRedeemCollateralBalance

Returns user's balance available for redemption


```solidity
function getRedeemCollateralBalance(address userAddress, uint256 collateralIndex) external view returns (uint256);
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
function getRedeemGovernanceBalance(address userAddress) external view returns (uint256);
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
function governanceEthPoolAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Pool address|


### stableUsdPriceFeedInformation

Returns chainlink price feed information for stable/USD pair

*Here stable coin refers to the 1st coin in the Curve's stable/Dollar plain pool*


```solidity
function stableUsdPriceFeedInformation() external view returns (address, uint256);
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
) external nonReentrant returns (uint256 totalDollarMint, uint256 collateralNeeded, uint256 governanceNeeded);
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


```solidity
function redeemDollar(uint256 collateralIndex, uint256 dollarAmount, uint256 governanceOutMin, uint256 collateralOutMin)
    external
    nonReentrant
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

Used to collect collateral tokens after redeeming/burning Ubiquity Dollars

*Redeem process is split in two steps:*


```solidity
function collectRedemption(uint256 collateralIndex)
    external
    nonReentrant
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
function updateChainLinkCollateralPrice(uint256 collateralIndex) external;
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
function amoMinterBorrow(uint256 collateralAmount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralAmount`|`uint256`|Amount of collateral to borrow|


### addAmoMinter

Adds a new AMO minter


```solidity
function addAmoMinter(address amoMinterAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amoMinterAddress`|`address`|AMO minter address|


### addCollateralToken

Adds a new collateral token


```solidity
function addCollateralToken(address collateralAddress, address chainLinkPriceFeedAddress, uint256 poolCeiling)
    external
    onlyAdmin;
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
function removeAmoMinter(address amoMinterAddress) external onlyAdmin;
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
) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralAddress`|`address`|Collateral token address|
|`chainLinkPriceFeedAddress`|`address`|ChainLink price feed address|
|`stalenessThreshold`|`uint256`|Threshold in seconds when chainlink answer should be considered stale|


### setCollateralRatio

Sets collateral ratio

*How much collateral/governance tokens user should provide/get to mint/redeem Dollar tokens, 1e6 precision*


```solidity
function setCollateralRatio(uint256 newCollateralRatio) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newCollateralRatio`|`uint256`|New collateral ratio|


### setEthUsdChainLinkPriceFeed

Sets chainlink params for ETH/USD price feed


```solidity
function setEthUsdChainLinkPriceFeed(address newPriceFeedAddress, uint256 newStalenessThreshold) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newPriceFeedAddress`|`address`|New chainlink price feed address for ETH/USD pair|
|`newStalenessThreshold`|`uint256`|New threshold in seconds when chainlink's ETH/USD price feed answer should be considered stale|


### setFees

Sets mint and redeem fees, 1_000_000 = 100%


```solidity
function setFees(uint256 collateralIndex, uint256 newMintFee, uint256 newRedeemFee) external onlyAdmin;
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
function setGovernanceEthPoolAddress(address newGovernanceEthPoolAddress) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newGovernanceEthPoolAddress`|`address`|New pool address for Governance/ETH pair|


### setPoolCeiling

Sets max amount of collateral for a particular collateral token


```solidity
function setPoolCeiling(uint256 collateralIndex, uint256 newCeiling) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralIndex`|`uint256`|Collateral token index|
|`newCeiling`|`uint256`|Max amount of collateral|


### setPriceThresholds

Sets mint and redeem price thresholds, 1_000_000 = $1.00


```solidity
function setPriceThresholds(uint256 newMintPriceThreshold, uint256 newRedeemPriceThreshold) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newMintPriceThreshold`|`uint256`|New mint price threshold|
|`newRedeemPriceThreshold`|`uint256`|New redeem price threshold|


### setRedemptionDelayBlocks

Sets a redemption delay in blocks

*Redeeming is split in 2 actions:*


```solidity
function setRedemptionDelayBlocks(uint256 newRedemptionDelayBlocks) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newRedemptionDelayBlocks`|`uint256`|Redemption delay in blocks|


### setStableUsdChainLinkPriceFeed

Sets chainlink params for stable/USD price feed

*Here stable coin refers to the 1st coin in the Curve's stable/Dollar plain pool*


```solidity
function setStableUsdChainLinkPriceFeed(address newPriceFeedAddress, uint256 newStalenessThreshold)
    external
    onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newPriceFeedAddress`|`address`|New chainlink price feed address for stable/USD pair|
|`newStalenessThreshold`|`uint256`|New threshold in seconds when chainlink's stable/USD price feed answer should be considered stale|


### toggleCollateral

Toggles (i.e. enables/disables) a particular collateral token


```solidity
function toggleCollateral(uint256 collateralIndex) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralIndex`|`uint256`|Collateral token index|


### toggleMintRedeemBorrow

Toggles pause for mint/redeem/borrow methods


```solidity
function toggleMintRedeemBorrow(uint256 collateralIndex, uint8 toggleIndex) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralIndex`|`uint256`|Collateral token index|
|`toggleIndex`|`uint8`|Method index. 0 - toggle mint pause, 1 - toggle redeem pause, 2 - toggle borrow by AMO pause|


