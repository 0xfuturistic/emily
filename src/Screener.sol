// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./CommitmentManager.sol";
import "./lib/types.sol";

contract Screener {
    CommitmentManager public immutable commitmentManager;

    constructor(address commitmentManagerAddress) {
        commitmentManager = CommitmentManager(commitmentManagerAddress);
    }

    modifier Screen(address user, bytes32 region, bytes memory value) {
        if (!screen(user, region, value)) revert UserConstraintsNotSatisfied(user, region, value);
        _;
    }

    function screen(address user, bytes32 region, bytes memory value) public view virtual returns (bool success) {
        success = commitmentManager.screen(user, region, value);
    }
}
