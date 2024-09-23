# UintUtils
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/c8e4c35e03024dbea12740d3dfedc8e8a0bad6a8/src/dollar/libraries/UintUtils.sol)

*Derived from https://github.com/OpenZeppelin/openzeppelin-contracts/ (MIT license)*

*https://github.com/solidstate-network/solidstate-solidity/blob/master/contracts/utils/UintUtils.sol*


## State Variables
### HEX_SYMBOLS
Hex symbols


```solidity
bytes16 private constant HEX_SYMBOLS = "0123456789abcdef";
```


## Functions
### add

Returns the addition of two unsigned integers, reverting on
overflow.
Counterpart to Solidity's `+` operator.
Requirements:
- Addition cannot overflow.


```solidity
function add(uint256 a, int256 b) internal pure returns (uint256);
```

### sub

Returns the subtraction of two unsigned integers, reverting on
overflow (when the result is negative).
Counterpart to Solidity's `-` operator.
Requirements:
- Subtraction cannot overflow.


```solidity
function sub(uint256 a, int256 b) internal pure returns (uint256);
```

### toString

Converts a `uint256` to its ASCII `string` decimal representation.


```solidity
function toString(uint256 value) internal pure returns (string memory);
```

### toHexString

Converts a `uint256` to its ASCII `string` decimal representation.


```solidity
function toHexString(uint256 value) internal pure returns (string memory);
```

### toHexString

Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.


```solidity
function toHexString(uint256 value, uint256 length) internal pure returns (string memory);
```

## Errors
### UintUtils__InsufficientHexLength
Thrown on insufficient hex length in `toHexString()`


```solidity
error UintUtils__InsufficientHexLength();
```

