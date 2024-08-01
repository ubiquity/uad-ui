// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../../../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../../../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SecurityMonitor is
    AccessControl,
    Pausable,
    ReentrancyGuard,
    AutomationCompatibleInterface
{
    using SafeMath for uint256;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");

    uint256 public lastCheckBlock;
    uint256 public liquidityThreshold;
    uint256 public constant CHECK_INTERVAL = 100; // Number of blocks between checks

    address public liquidityPool;
    IERC20 public monitoredToken;
    AggregatorV3Interface public priceOracle;

    mapping(address => bool) public contractsToPause;
    address[] public pausableContracts;

    event SecurityIncident(string message);
    event LiquidityThresholdUpdated(uint256 newThreshold);
    event ContractPaused(address pausedContract);
    event ContractUnpaused(address unpausedContract);

    constructor(
        address admin,
        uint256 _liquidityThreshold,
        address _liquidityPool,
        address _monitoredToken,
        address _priceOracle
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(PAUSER_ROLE, admin);
        _setupRole(UPDATER_ROLE, admin);

        liquidityThreshold = _liquidityThreshold;
        lastCheckBlock = block.number;
        liquidityPool = _liquidityPool;
        monitoredToken = IERC20(_monitoredToken);
        priceOracle = AggregatorV3Interface(_priceOracle);
    }

    function checkLiquidity() public view returns (bool) {
        uint256 poolBalance = monitoredToken.balanceOf(liquidityPool);
        (, int256 price, , , ) = priceOracle.latestRoundData();
        require(price > 0, "Invalid price data");

        uint256 poolValue = poolBalance.mul(uint256(price)).div(1e18);
        return poolValue < liquidityThreshold;
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        upkeepNeeded =
            (block.number.sub(lastCheckBlock) >= CHECK_INTERVAL) &&
            !paused();
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external override nonReentrant {
        require(
            block.number.sub(lastCheckBlock) >= CHECK_INTERVAL,
            "Check interval not reached"
        );
        require(!paused(), "Contract is paused");

        if (checkLiquidity()) {
            pauseAllContracts();
            notifyTeam(
                "Security incident detected: Liquidity threshold breached. Contracts paused."
            );
        }
        lastCheckBlock = block.number;
    }

    function pauseAllContracts() public onlyRole(PAUSER_ROLE) whenNotPaused {
        _pause();
        for (uint i = 0; i < pausableContracts.length; i++) {
            if (contractsToPause[pausableContracts[i]]) {
                // Assume each contract has a pause() function
                (bool success, ) = pausableContracts[i].call(
                    abi.encodeWithSignature("pause()")
                );
                if (success) {
                    emit ContractPaused(pausableContracts[i]);
                }
            }
        }
        emit SecurityIncident(
            "All contracts paused due to a security incident."
        );
    }

    function unpauseAllContracts() public onlyRole(PAUSER_ROLE) whenPaused {
        _unpause();
        for (uint i = 0; i < pausableContracts.length; i++) {
            if (contractsToPause[pausableContracts[i]]) {
                // Assume each contract has an unpause() function
                (bool success, ) = pausableContracts[i].call(
                    abi.encodeWithSignature("unpause()")
                );
                if (success) {
                    emit ContractUnpaused(pausableContracts[i]);
                }
            }
        }
        emit SecurityIncident(
            "All contracts unpaused. Security incident resolved."
        );
    }

    function notifyTeam(string memory message) public onlyRole(PAUSER_ROLE) {
        // In a real-world scenario, you might want to integrate with an external
        // notification service here. For now, we'll just emit an event.
        emit SecurityIncident(message);
    }

    function addPausableContract(
        address _contract
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!contractsToPause[_contract], "Contract already added");
        contractsToPause[_contract] = true;
        pausableContracts.push(_contract);
    }

    function removePausableContract(
        address _contract
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(contractsToPause[_contract], "Contract not found");
        contractsToPause[_contract] = false;
        for (uint i = 0; i < pausableContracts.length; i++) {
            if (pausableContracts[i] == _contract) {
                pausableContracts[i] = pausableContracts[
                    pausableContracts.length - 1
                ];
                pausableContracts.pop();
                break;
            }
        }
    }

    function updateLiquidityThreshold(
        uint256 _newThreshold
    ) public onlyRole(UPDATER_ROLE) {
        liquidityThreshold = _newThreshold;
        emit LiquidityThresholdUpdated(_newThreshold);
    }

    function updateLiquidityPool(
        address _newPool
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        liquidityPool = _newPool;
    }

    function updateMonitoredToken(
        address _newToken
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        monitoredToken = IERC20(_newToken);
    }

    function updatePriceOracle(
        address _newOracle
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        priceOracle = AggregatorV3Interface(_newOracle);
    }

    function getContractsPauseStatus()
        public
        view
        returns (address[] memory, bool[] memory)
    {
        bool[] memory statuses = new bool[](pausableContracts.length);
        for (uint i = 0; i < pausableContracts.length; i++) {
            statuses[i] = contractsToPause[pausableContracts[i]];
        }
        return (pausableContracts, statuses);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
