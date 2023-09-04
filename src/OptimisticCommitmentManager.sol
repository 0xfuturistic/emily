// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./CommitmentManager.sol";
import "./lib/types.sol";

contract OptimisticCommitmentManager is CommitmentManager {
    constructor(uint256 accountCommitmentsGasLimit) CommitmentManager(accountCommitmentsGasLimit) {}

    struct PendingScreening {
        address account;
        bytes32 target;
        bytes value;
        uint256 timestamp;
    }

    PendingScreening[] public pendingScreenings;

    function challengePendingScreening(uint256 id) external {
        PendingScreening memory pendingScreening = pendingScreenings[id];
    }
}
