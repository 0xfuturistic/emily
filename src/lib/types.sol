// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Lib.sol";

struct Commitment {
    function (bytes memory) external view returns (uint256) indicatorFunction;
}

error CommitmentNotSatisfied(Commitment commitment, bytes value, uint256 totalGasLimit);
error AccountCommitmentFailed(address account, bytes32 domain, bytes value);
