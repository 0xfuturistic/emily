// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Lib.sol";

/// @dev An assignment of a value to a region.
struct Assignment {
    bytes32 domainRoot;
    bytes value;
}

struct AssignmentSet {
    Assignment[] inner;
}

/// @dev A commitment is a relation defined on a domain.
struct Commitment {
    bytes32 domainRoot;
    /// @dev The relation is defined intensionally by a formula.
    ///      The domain is an instance (an assignment of values)
    //       but here we define it more generally as a bytes array.
    function (bytes memory) external view returns(bool) relation;
}

struct CommitmentSet {
    Commitment[] inner;
}

using CommitmentsLib for Commitment global;
using CommitmentsLib for CommitmentSet global;

error UserCommitmentsNotSatisfied(address user, bytes32 region, bytes value);
