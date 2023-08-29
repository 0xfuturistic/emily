// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./CommitmentManager.sol";
import "./lib/types.sol";

/// @title Screener
/// @notice A contract that screens an arbitrary value written to a target by an account
///         for the satisfaction of the account's commitments at the value being written.
contract Screener {
    /// @notice The commitment manager contract that holds the commitments to be screened against.
    CommitmentManager public immutable commitmentManager;

    /// @notice Constructs a new Screener contract instance.
    /// @param commitmentManagerAddress The address of the commitment manager contract.
    constructor(address commitmentManagerAddress) {
        commitmentManager = CommitmentManager(commitmentManagerAddress);
    }

    /// @notice Modifier that checks if the account's commitments are satisfied by the value being written.
    /// @param account The account that is writing the value.
    /// @param target The target to which the value is being written.
    /// @param value The value being written.
    modifier Screen(address account, bytes32 target, bytes memory value) {
        if (!screen(account, target, value)) revert AccountCommitmentFailed(account, target, value);
        _;
    }

    /// @notice Checks if the account's commitments are satisfied by the value being written.
    /// @param account The account that is writing the value.
    /// @param target The target to which the value is being written.
    /// @param value The value being written.
    /// @return True if the account's commitments are satisfied by the value being written, false otherwise.
    function screen(address account, bytes32 target, bytes memory value) public view virtual returns (bool) {
        return commitmentManager.areAccountCommitmentsSatisfiedByValue(account, target, value);
    }
}
