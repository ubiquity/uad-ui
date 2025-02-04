// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

/**
 * @title GovernanceRewardsSplitter
 * @notice A configurable mono ERC20 payment splitter.
 * @dev This contract allows to split governance token payments among a group of accounts. The sender does not need to be aware
 * that the ERC20 will be split in this way, since it is handled transparently by the contract.
 *
 * The split can be in equal parts or in any other arbitrary proportion. The way this is specified is by assigning each
 * account to a number of shares. Of all tokens that this contract receives, each account will then be able to claim
 * an amount proportional to the percentage of total shares they were assigned.
 *
 * This contract is configurable by the owner, meaning the owner can update the split configuration at any time.
 * `GovernanceRewardsSplitter` follows a _pull payment_ model, where payments are not automatically forwarded to the
 * accounts but kept in this contract. The actual transfer is triggered as a separate step by calling the {release}
 * function.
 *
 * NOTE: This contract assumes that ERC20 tokens will behave similarly to native tokens (Ether). Rebasing tokens, and
 * tokens that apply fees during transfers, are likely to not be supported as expected.
 */
contract GovernanceRewardsSplitter is Ownable {
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    IERC20 public constant governanceToken = IERC20(address(0x0));

    event PayeeAdded(address account, uint256 shares);
    event PayeeEdited(address account, uint256 newShares);
    event PayeeDeleted(address account);
    event GovernanceTokenReleased(
        IERC20 governanceToken,
        address indexed to,
        uint256 amount
    );

    EnumerableMap.AddressToUintMap private _payeesToShares;
    uint256 public totalShares;

    uint256 public governanceTokenTotalReleased;
    mapping(address => uint256) public accountToGovernanceTokenReleased;

    /**
     * @dev Creates an instance of `GovernanceRewardsSplitter` where each account in `payees` is assigned the number of shares at
     * the matching position in the `shares` array.
     *
     * All addresses in `payees` must be non-zero. Both arrays must have the same non-zero length, and there must be no
     * duplicates in `payees`.
     */
    constructor(address[] memory payees, uint256[] memory shares_) payable {
        require(
            payees.length == shares_.length,
            "GovernanceRewardsSplitter: payees and shares length mismatch"
        );
        require(payees.length > 0, "GovernanceRewardsSplitter: no payees");

        // Initialize payees and shares
        for (uint256 i = 0; i < payees.length; i++) {
            addPayee(payees[i], shares_[i]);
        }
    }

    /**
     * @dev Triggers a transfer to `account` of the amount of `governanceToken` tokens they are owed, according to their
     * percentage of the total shares and their previous withdrawals.
     */
    function release(address account) public virtual {
        require(
            _payeesToShares.contains(account),
            "GovernanceRewardsSplitter: account has no shares"
        );

        uint256 payment = releasable(account);

        require(
            payment != 0,
            "GovernanceRewardsSplitter: account is not due payment"
        );

        governanceTokenTotalReleased += payment;
        unchecked {
            accountToGovernanceTokenReleased[account] += payment;
        }

        SafeERC20.safeTransfer(governanceToken, account, payment);
        emit GovernanceTokenReleased(governanceToken, account, payment);
    }

    /**
     * @dev Add a new payee to the contract.
     * @param account The address of the payee to add.
     * @param shares_ The number of shares owned by the payee.
     */
    function addPayee(address account, uint256 shares_) public onlyOwner {
        require(
            account != address(0),
            "GovernanceRewardsSplitter: account is the zero address"
        );
        require(shares_ > 0, "GovernanceRewardsSplitter: shares are 0");
        require(
            !_payeesToShares.contains(account),
            "GovernanceRewardsSplitter: account already has shares"
        );

        _payeesToShares.set(account, shares_);
        totalShares += shares_;
        emit PayeeAdded(account, shares_);
    }

    /**
     * @dev Edit an existing payee's shares.
     * @param account The address of the payee to edit.
     * @param newShares The new number of shares owned by the payee.
     */
    function editPayee(address account, uint256 newShares) public onlyOwner {
        require(
            _payeesToShares.contains(account),
            "GovernanceRewardsSplitter: account does not exist"
        );
        require(
            newShares > 0,
            "GovernanceRewardsSplitter: new shares must be greater than 0"
        );

        uint256 oldShares = _payeesToShares.get(account);
        totalShares = totalShares - oldShares + newShares;
        _payeesToShares.set(account, newShares);
        emit PayeeEdited(account, newShares);
    }

    /**
     * @dev Delete an existing payee from the contract.
     * @param account The address of the payee to delete.
     */
    function deletePayee(address account) public onlyOwner {
        require(
            _payeesToShares.contains(account),
            "GovernanceRewardsSplitter: account does not exist"
        );

        uint256 shares = _payeesToShares.get(account);
        totalShares -= shares;
        _payeesToShares.remove(account);
        emit PayeeDeleted(account);
    }

    /**
     * @dev Getter for all current payees.
     */
    function currentPayees() public view returns (address[] memory) {
        address[] memory payees = new address[](_payeesToShares.length());
        for (uint256 i = 0; i < _payeesToShares.length(); i++) {
            (address payee, ) = _payeesToShares.at(i);
            payees[i] = payee;
        }
        return payees;
    }

    /**
     * @dev Getter for the current amount of shares held by an account.
     */
    function currentShares(address account) public view returns (uint256) {
        (, uint256 shares) = _payeesToShares.tryGet(account);
        return shares;
    }

    /**
     * @dev Getter for the total shares held by all payees.
     */
    function currentTotalShares() public view returns (uint256) {
        return totalShares;
    }

    /**
     * @dev Getter for the amount of payee's releasable `governanceToken` tokens.
     */
    function releasable(address account) public view returns (uint256) {
        uint256 totalReceived = governanceToken.balanceOf(address(this)) +
            governanceTokenTotalReleased;
        return
            _pendingPayment(
                account,
                totalReceived,
                accountToGovernanceTokenReleased[account]
            );
    }

    /**
     * @dev Internal logic for computing the pending payment of an `account` given the governanceToken historical balances and
     * already released amounts.
     */
    function _pendingPayment(
        address account,
        uint256 totalReceived,
        uint256 alreadyReleased
    ) private view returns (uint256) {
        uint256 shares = _payeesToShares.get(account);
        return (totalReceived * shares) / totalShares - alreadyReleased;
    }
}
