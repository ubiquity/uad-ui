# MockChainLinkFeed
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/0cae71618450aff584ed3369a18e2ba12900dc6b/src/dollar/mocks/MockChainLinkFeed.sol)

**Inherits:**
AggregatorV3Interface


## State Variables
### roundId

```solidity
uint80 roundId;
```


### answer

```solidity
int256 answer;
```


### startedAt

```solidity
uint256 startedAt;
```


### updatedAt

```solidity
uint256 updatedAt;
```


### answeredInRound

```solidity
uint80 answeredInRound;
```


### decimals

```solidity
uint8 public decimals;
```


## Functions
### constructor


```solidity
constructor();
```

### description


```solidity
function description() external pure override returns (string memory);
```

### version


```solidity
function version() external pure override returns (uint256);
```

### getRoundData


```solidity
function getRoundData(uint80) external view override returns (uint80, int256, uint256, uint256, uint80);
```

### latestRoundData


```solidity
function latestRoundData() external view override returns (uint80, int256, uint256, uint256, uint80);
```

### updateDecimals


```solidity
function updateDecimals(uint8 _newDecimals) public;
```

### updateMockParams


```solidity
function updateMockParams(
    uint80 _roundId,
    int256 _answer,
    uint256 _startedAt,
    uint256 _updatedAt,
    uint80 _answeredInRound
) public;
```

