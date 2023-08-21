// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./types.sol";

/// @title Constraints Library
/// @dev A library for testing instances of assignments on constraints.
library ConstraintsLib {
    error NotInScope();

    /// @dev Tests that an instance in the scope of a constraint satisfies the constraint.
    /// @param self Constraint
    /// @param instance Instance to test
    /// @param gasLimit Gas limit for evaluating the constraint
    /// @return success Whether the test passed (iff constraint is satisfied).
    function isSatisfied(Constraint memory self, Assignment[] memory instance, uint256 gasLimit)
        public
        view
        returns (bool success)
    {
        if (!inScope(self, instance)) {
            /// @dev Assumption violated.
            revert NotInScope();
        }
        /// @dev Test whether the constraint's relation holds for the instance for the given gas limit.
        (success,) =
            self.relation.address.staticcall{gas: gasLimit}(abi.encodeWithSelector(self.relation.selector, instance));
    }

    /// @dev Checks whether an instance is in the scope of the constraint.
    /// @param self Constraint
    /// @param instance Instance to check
    /// @return isInScope Whether the instance is in scope
    function inScope(Constraint memory self, Assignment[] memory instance) public pure returns (bool isInScope) {
        /// @dev Assume that the instance is in scope.
        isInScope = true;
        /// @dev Now check if there's a contradiction.
        for (uint256 i = 0; i < self.indicesInScope.length; i++) {
            if (self.indicesInScope[i] != instance[i].index) {
                isInScope = false;
                break;
            }
        }
    }
}
