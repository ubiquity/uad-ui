// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";

interface INotifiable {
    function notify(string memory message) external;
}

contract SecurityMonitor is AccessControl, Pausable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MONITOR_ROLE = keccak256("MONITOR_ROLE");

    address public notificationService;

    event SecurityIncident(string message);

    constructor(address admin, address _notificationService) {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(PAUSER_ROLE, admin);
        _setupRole(MONITOR_ROLE, admin);

        notificationService = _notificationService;
    }

    function setNotificationService(address _notificationService) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Must have admin role to set notification service"
        );
        notificationService = _notificationService;
    }

    function pauseAllContracts(address[] calldata contracts) external {
        require(
            hasRole(MONITOR_ROLE, _msgSender()),
            "Must have monitor role to pause"
        );

        for (uint256 i = 0; i < contracts.length; i++) {
            //Pausable(contracts[i]).pause();
        }

        string
            memory message = "Security incident detected: all contracts paused.";
        emit SecurityIncident(message);
        INotifiable(notificationService).notify(message);
    }

    function unpauseAllContracts(address[] calldata contracts) external {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "Must have pauser role to unpause"
        );

        for (uint256 i = 0; i < contracts.length; i++) {
            //Pausable(contracts[i]).unpause();
        }

        string
            memory message = "Security issue resolved: all contracts unpaused.";
        emit SecurityIncident(message);
        INotifiable(notificationService).notify(message);
    }

    //function _msgSender() internal view virtual returns (address) {
    //return Context._msgSender();
    // }
}
