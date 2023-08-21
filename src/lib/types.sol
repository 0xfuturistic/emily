// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Lib.sol";

/// @dev An assignment of a value to a variable in a region with a region root
struct Assignment {
    uint256 regionRoot;
    bytes value;
}

struct AssignmentSet {
    Assignment[] inner;
}

/// @dev A constraint is a relation defined on a scope.
struct Constraint {
    uint256 regionRoot;
    /// @dev The relation is defined intensionally by a formula.
    ///      The domain is an instance (an assignment of values) for variables
    ///      in the scope.
    function (bytes memory) external view returns(bool) relation;
}

struct ConstraintSet {
    Constraint[] inner;
}

using ConstraintsLib for Constraint global;
