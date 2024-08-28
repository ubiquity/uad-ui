// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "../interfaces/ITelegramNotifier.sol";

contract MockTelegramNotifier is ITelegramNotifier {
    event NotificationSent(string message);

    bool public lastNotificationSent;

    string public lastNotificationMessage;

    function notify(string memory message) external override {
        lastNotificationSent = true;

        lastNotificationMessage = message;

        emit NotificationSent(message);
    }

    function resetNotification() external {
        lastNotificationSent = false;

        lastNotificationMessage = "";
    }
}
