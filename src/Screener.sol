// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./CommitmentManager.sol";
import "./lib/types.sol";

/// @title Screener
/// @dev A contract that provides a modifier to screen function calls
///      for the satisfaction of a user's commitments.
contract Screener {
    CommitmentManager public immutable commitmentManager;

    constructor(address commitmentManagerAddress) {
        commitmentManager = CommitmentManager(commitmentManagerAddress);
    }

    /// @dev Modifier to screen user commitments before executing a
    ///      function. Reverts if the user commitments are not satisfied.
    /// @param user The address of the user.
    /// @param domain The domain of the commitment.
    /// @param value The value of the commitment.
    modifier Screen(address user, bytes32 domain, bytes memory value) {
        if (!screen(user, domain, value)) revert UserCommitmentsNotSatisfied(user, domain, value);
        _;
    }

    /// @dev Checks if the user commitments are satisfied.
    /// @param user The address of the user.
    /// @param domain The domain of the commitment.
    /// @param value The value of the commitment.
    /// @return True if and only if the user's commitments are satisfied.
    function screen(address user, bytes32 domain, bytes memory value) public view virtual returns (bool) {
        return commitmentManager.areUserCommitmentsSatisfied(user, domain, value);
    }
}
