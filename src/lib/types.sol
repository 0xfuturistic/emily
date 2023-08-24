// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Lib.sol";

/// @dev A commitment is a relation defined on a domain.
struct Commitment {
    bytes32 domainRoot;
    /// @dev The relation is defined intensionally by a formula.
    ///      The domain is an instance (an assignment of values)
    //       but here we define it more generally as a bytes array.
    function (bytes memory) external view relation;
}

/// @dev CommitmentSet is a set of commitments. Commitments are
///      stored in the inner array of the CommitmentSet struct.
struct CommitmentSet {
    Commitment[] inner;
}

/// @dev An assignment of a value on a domain.
struct Assignment {
    bytes32 domainRoot;
    bytes value;
}

using CommitmentSetLib for CommitmentSet global;

error UserCommitmentsNotSatisfied(address user, bytes32 domain, bytes value);
