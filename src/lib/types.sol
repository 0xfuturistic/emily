// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Lib.sol";

/// @title Commitment
/// @dev A commitment extensionally defines a subet of values that satisfy it for a target.
///      The indicator function returns 1 if and only if the value is in such a subset.
struct Commitment {
    uint256 timestamp;
    function (bytes memory) external view returns (uint256) indicatorFunction;
}

/// @dev An error thrown when a commitment is not satisfied.
error CommitmentNotSatisfied(Commitment commitment, bytes value, uint256 totalGasLimit);

/// @dev An error thrown when an account's commitment fails.
error AccountCommitmentFailed(address account, bytes32 domain, bytes value);
