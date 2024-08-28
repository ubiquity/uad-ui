// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// File: ./mocks/MockUbiquityDollarToken.sol
contract MockUbiquityDollarToken {
    bool public paused;

    function pause() external {
        paused = true;
    }

    function unpause() external {
        paused = false;
    }
}
