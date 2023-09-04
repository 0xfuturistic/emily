// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./CommitmentManager.sol";
import "./lib/types.sol";

/// @title Screener
/// @notice A contract that checks if an account's commitments are satisfied by the value being written to a target.
contract Screener {
    /// @notice The commitment manager contract that holds the commitments to be screened against.
    CommitmentManager public immutable commitmentManager;

    error AccountScreeningFailed(address account, bytes32 target, bytes value);

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
        if (!screen(account, target, value)) revert AccountScreeningFailed(account, target, value);
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
