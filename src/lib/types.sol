// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Lib.sol";

struct Constraint {
    bytes32 scope;
    // The relation is defined intensionally by a formula.
    // The domain is an instance (an assignment of values)
    //       but here we define it more generally as a bytes array.
    function (bytes memory) external view returns (bool) relation;
}

struct Commitment {
    Constraint[] inner;
}

struct Assignment {
    bytes32 target;
    bytes value;
}

using CommitmentLib for Commitment global;
using CommitmentLib for Constraint global;
using CommitmentLib for Assignment global;

error CommitmentFailed(address user, bytes32 domain, bytes value);

error NotConstraintSolution(Constraint constraint, bytes[] valuesInScope, uint256 totalGasLimit);
