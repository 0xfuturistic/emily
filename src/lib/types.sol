// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Lib.sol";

/// @dev An assignment of a value to a region.
struct Assignment {
    bytes32 regionRoot;
    bytes value;
}

struct AssignmentSet {
    Assignment[] inner;
}

/// @dev A constraint is a relation defined on a region.
struct Constraint {
    bytes32 regionRoot;
    /// @dev The relation is defined intensionally by a formula.
    ///      The domain is an instance (an assignment of values)
    //       but here we define it more generally as a bytes array.
    function (bytes memory) external view returns(bool) relation;
}

struct ConstraintSet {
    Constraint[] inner;
}

using ConstraintsLib for Constraint global;
using ConstraintsLib for ConstraintSet global;

error UserConstraintsNotSatisfied(address user, bytes32 region, bytes value);
