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

    modifier Screen(address account, bytes32 domain, bytes memory value) {
        if (!screen(account, domain, value)) revert AccountCommitmentFailed(account, domain, value);
        _;
    }

    function screen(address account, bytes32 target, bytes memory value) public view virtual returns (bool) {
        return commitmentManager.isAccountCommitmentSatisfied(account, target, value);
    }
}
