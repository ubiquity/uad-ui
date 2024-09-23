# MockCurveStableSwapNG
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/mocks/MockCurveStableSwapNG.sol)

**Inherits:**
[ICurveStableSwapNG](/src/dollar/interfaces/ICurveStableSwapNG.sol/interface.ICurveStableSwapNG.md), [MockCurveStableSwapMetaNG](/src/dollar/mocks/MockCurveStableSwapMetaNG.sol/contract.MockCurveStableSwapMetaNG.md)


## Functions
### constructor


```solidity
constructor(address _token0, address _token1) MockCurveStableSwapMetaNG(_token0, _token1);
```

### add_liquidity


```solidity
function add_liquidity(uint256[] memory _amounts, uint256 _min_mint_amount, address _receiver)
    external
    returns (uint256 result);
```

