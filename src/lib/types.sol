// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Lib.sol";

type RowId is uint256;

struct Assignment {
    RowId row_id;
    bytes value;
}

struct Constraint {
    /// @dev List of row ids in the scope.
    RowId[] scope;
    /// @dev The relation is defined intensionally by a formula, the characteristic function
    ///      the input is a list of values for the variables in the scope.
    function (bytes memory) external view returns(bool) relation;
}

using ConstraintsLib for Constraint global;
