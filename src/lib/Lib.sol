// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./types.sol";

/// @title Commitments Library
/// @dev A library for CommitmentSet and Commitment.
library CommitmentsLib {
    error NotInScope();

    function add(CommitmentSet storage self, Commitment memory commitment) public {
        self.inner.push(commitment);
    }

    function isConsistent(CommitmentSet storage self, Assignment memory assignment, uint256 totalGasLimit)
        public
        view
        returns (bool success)
    {
        /// @dev If self is empty, self is considered consistent
        ///      for any assignment and any totalGasLimit.
        if (self.inner.length == 0) {
            return true;
        }

        /// @dev Checks if all the commitments in self are satisfied
        //       by the assignment.
        uint256 perCommitmentGasLimit = totalGasLimit / self.inner.length;
        for (uint256 i = 0; i < self.inner.length; i++) {
            if (!isSatisfied(self.inner[i], assignment, perCommitmentGasLimit)) {
                return false;
            }
        }
        return true;
    }

    function isSatisfied(Commitment memory self, Assignment memory assignment, uint256 commitmentGasLimit)
        public
        view
        returns (bool success)
    {
        /// @dev If assignment is not in the scope of self, self is
        ///      considered satisfied for any totalGasLimit.
        if (self.domainRoot != assignment.domainRoot) {
            return true;
        }
        /// @dev Evaluates the relation of self at the assignment with
        ///      commitmentGasLimit.
        (success,) = self.relation.address.staticcall{gas: commitmentGasLimit}(
            abi.encodeWithSelector(self.relation.selector, assignment)
        );
    }
}
