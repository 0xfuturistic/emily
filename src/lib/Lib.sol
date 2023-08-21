// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./types.sol";

/// @title Constraints Library
/// @dev A library for ConstraintSet and Constraint.
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
        /// @dev If self is empty, self is considered consistent
        ///      for any assignment and any totalGasLimit.
        if (self.inner.length == 0) {
            return true;
        }

        /// @dev Checks if all the constraints in self are satisfied
        //       by the assignment.
        uint256 perConstraintGasLimit = totalGasLimit / self.inner.length;
        for (uint256 i = 0; i < self.inner.length; i++) {
            if (!isSatisfied(self.inner[i], assignment, perConstraintGasLimit)) {
                return false;
            }
        }
        return true;
    }

    function isSatisfied(Constraint memory self, Assignment memory assignment, uint256 constraintGasLimit)
        public
        view
        returns (bool success)
    {
        /// @dev If assignment is not in the scope of self, self is
        ///      considered satisfied for any totalGasLimit.
        if (self.regionRoot != assignment.regionRoot) {
            return true;
        }
        /// @dev Evaluates the relation of self at the assignment with
        ///      constraintGasLimit.
        (success,) = self.relation.address.staticcall{gas: constraintGasLimit}(
            abi.encodeWithSelector(self.relation.selector, assignment)
        );
    }
}
