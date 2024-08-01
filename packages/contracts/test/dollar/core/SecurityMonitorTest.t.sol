// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../../../src/dollar/utils/SecurityMonitor.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Mock ERC20 token contract for testing
contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

// Mock Price Oracle contract for testing
contract MockPriceOracle {
    int256 private price;

    function setPrice(int256 _price) external {
        price = _price;
    }

    function latestRoundData()
        external
        view
        returns (uint80, int256, uint256, uint256, uint80)
    {
        return (0, price, 0, 0, 0);
    }
}

// Mock Pausable contract for testing
contract MockPausableContract is Pausable {
    function pause() external {
        _pause();
    }

    function unpause() external {
        _unpause();
    }
}

contract SecurityMonitorTest is Test {
    SecurityMonitor securityMonitor;
    MockERC20 mockToken;
    MockPriceOracle mockPriceOracle;
    MockPausableContract mockPausableContract;

    event SecurityIncident(string message);

    function setUp() public {
        mockToken = new MockERC20("MockToken", "MTK");
        mockPriceOracle = new MockPriceOracle();
        mockPausableContract = new MockPausableContract();

        securityMonitor = new SecurityMonitor(
            address(this),
            1000 * 10 ** 18,
            address(this),
            address(mockToken),
            address(mockPriceOracle)
        );

        securityMonitor.grantRole(securityMonitor.PAUSER_ROLE(), address(this));
        securityMonitor.addPausableContract(address(mockPausableContract));
    }

    function testPauseAllContracts() public {
        vm.expectEmit(false, false, false, true);
        emit SecurityIncident(
            "All contracts paused due to a security incident."
        );

        securityMonitor.pauseAllContracts();
        assertTrue(mockPausableContract.paused());
    }

    function testNotifyTeam() public {
        string memory incidentMessage = "Test incident";

        vm.expectEmit(false, false, false, true);
        emit SecurityIncident(incidentMessage);

        securityMonitor.notifyTeam(incidentMessage);
    }

    function testCheckLiquidity() public {
        // Get the liquidity pool address
        address liquidityPool = securityMonitor.liquidityPool();

        // Mint tokens to the liquidity pool
        mockToken.mint(liquidityPool, 2000 * 10 ** 18);
        mockPriceOracle.setPrice(1 * 10 ** 18);

        // Liquidity should be above threshold (2000 > 1000)
        assertFalse(
            securityMonitor.checkLiquidity(),
            "Liquidity should be above threshold"
        );

        // Set price to 0.4, making liquidity fall below threshold (2000 * 0.4 = 800 < 1000)
        mockPriceOracle.setPrice(4 * 10 ** 17);

        // Liquidity should now be below threshold
        assertTrue(
            securityMonitor.checkLiquidity(),
            "Liquidity should be below threshold"
        );

        // Mint more tokens to bring liquidity above threshold again
        mockToken.mint(liquidityPool, 3000 * 10 ** 18);

        // Liquidity should now be above threshold (5000 * 0.4 = 2000 > 1000)
        assertFalse(
            securityMonitor.checkLiquidity(),
            "Liquidity should be above threshold after minting more tokens"
        );
    }

    function testPerformUpkeep() public {
        mockToken.mint(address(this), 500 * 10 ** 18);
        mockPriceOracle.setPrice(4 * 10 ** 17);

        vm.roll(block.number + 100);

        vm.expectEmit(false, false, false, true);
        emit SecurityIncident(
            "Security incident detected: Liquidity threshold breached. Contracts paused."
        );

        securityMonitor.performUpkeep("");
        assertTrue(securityMonitor.paused());
    }

    function testAddAndRemovePausableContracts() public {
        address newContract = address(0x123);

        securityMonitor.addPausableContract(newContract);
        (address[] memory contracts, bool[] memory statuses) = securityMonitor
            .getContractsPauseStatus();
        assertEq(contracts[contracts.length - 1], newContract);
        assertTrue(statuses[statuses.length - 1]);

        securityMonitor.removePausableContract(newContract);
        (contracts, statuses) = securityMonitor.getContractsPauseStatus();
        assertTrue(contracts.length == 1);
    }

    function testUpdateLiquidityThreshold() public {
        securityMonitor.updateLiquidityThreshold(2000 * 10 ** 18);
        assertEq(securityMonitor.liquidityThreshold(), 2000 * 10 ** 18);
    }

    function testUpdateLiquidityPool() public {
        address newPool = address(0x123);
        securityMonitor.updateLiquidityPool(newPool);
        assertEq(securityMonitor.liquidityPool(), newPool);
    }
}
