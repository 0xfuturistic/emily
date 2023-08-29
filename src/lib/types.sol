// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Lib.sol";

struct Commitment {
    function (Assignment memory) external view returns (uint256)[] indicator;
}

struct Assignment {
    bytes32 target;
    bytes value;
}

using CommitmentLib for Commitment global;
using CommitmentLib for Assignment global;

error CommitmentNotSatisfied(Commitment commitment, Assignment assignment, uint256 totalGasLimit);
error AccountCommitmentFailed(address account, bytes32 domain, bytes value);
