// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface ITelegramNotifier {
    /**

 * @notice Sends a notification message via Telegram

 * @param message The message to be sent

 */

    function notify(string memory message) external;
}
