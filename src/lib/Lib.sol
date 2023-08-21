// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./types.sol";

using EnumerableSet for EnumerableSet.Bytes32Set;
using EnumerableSet for EnumerableSet.UintSet;

/// @title Constraints Library
/// @dev A library for testing instances of assignments on constraints.
library ConstraintsLib {
    error NotInScope();

    function add(ConstraintSet storage self, Constraint memory constraint) public {
        self.inner.push(constraint);
    }

    function isConsistent(ConstraintSet storage self, Assignment memory assignment, uint256 totalGasLimit)
        public
        view
        returns (bool success)
    {
        if (self.inner.length == 0) {
            /// @dev If the constraint set is empty, it is vacuously consistent.
            return true;
        }

        uint256 perConstraintGasLimit = totalGasLimit / self.inner.length;
        /// @dev Checks if the assignment is consistent with all constraints in the set.
        for (uint256 i = 0; i < self.inner.length; i++) {
            if (!isSatisfied(self.inner[i], assignment, perConstraintGasLimit)) {
                return false;
            }
        }
        return true;
    }

    function isSatisfied(Constraint storage self, Assignment memory assignment, uint256 gasLimit)
        public
        view
        returns (bool success)
    {
        if (self.regionRoot != assignment.regionRoot) {
            /// @dev If the assignment's id is not in scope, the constraint's relation is vacuously satisfied.
            return true;
        }
        /// @dev Evaluates the constraint's relation at the assignment with the given gas limit.
        (success,) =
            self.relation.address.staticcall{gas: gasLimit}(abi.encodeWithSelector(self.relation.selector, assignment));
    }
}
