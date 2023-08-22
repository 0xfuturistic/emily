// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./CommitmentManager.sol";
import "./lib/types.sol";

contract Screener {
    CommitmentManager public immutable commitmentManager;

    constructor(address commitmentManagerAddress) {
        commitmentManager = CommitmentManager(commitmentManagerAddress);
    }

    modifier Screen(address user, bytes32 domain, bytes memory value) {
        if (!screen(user, domain, value)) revert UserCommitmentsNotSatisfied(user, domain, value);
        _;
    }

    function screen(address user, bytes32 domain, bytes memory value) public view virtual returns (bool success) {
        success = commitmentManager.screen(user, domain, value);
    }
}
