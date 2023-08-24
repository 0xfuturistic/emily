// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./types.sol";

/// @title CommitmentSet Library
/// @dev A library for CommitmentSet.
library CommitmentSetLib {
    /// @dev Returns an empty CommitmentSet.
    /// @return set An empty CommitmentSet.
    function identity() public pure returns (CommitmentSet memory set) {
        set = CommitmentSet(new Commitment[](0));
    }

    /// @dev Adds a CommitmentSet to another CommitmentSet.
    /// @param self The CommitmentSet to add to.
    /// @param set The CommitmentSet to add.
    function add(CommitmentSet storage self, CommitmentSet memory set) internal {
        for (uint256 i = 0; i < set.inner.length; i++) {
            self.inner.push(set.inner[i]);
        }
    }

    /// @dev Checks if a CommitmentSet is satisfied by an Assignment.
    /// @param self The CommitmentSet to check.
    /// @param assignment The Assignment to check against.
    /// @param totalGasLimit The total gas limit for the CommitmentSet.
    /// @return True if the CommitmentSet is satisfied, false otherwise.
    function isSatisfied(CommitmentSet storage self, Assignment memory assignment, uint256 totalGasLimit)
        public
        view
        returns (bool)
    {
        /// @dev If self is empty, self is considered consistent
        ///      for any assignment and any gasLimit.
        if (self.inner.length == 0) {
            return true;
        }

        /// @dev Checks if all the commitments in self are satisfied by
        //       the assignment
        uint256 perCommitmentGasLimit = totalGasLimit / self.inner.length;
        for (uint256 i = 0; i < self.inner.length; i++) {
            /// @dev If assignment is not in the domain of the commitment, the
            ///      commitment is considered satisfied for any gasLimit.
            if (self.inner[i].domainRoot != assignment.domainRoot) {
                continue;
            }
            /// @dev Evaluates the relation of commitment at the assignment with
            ///      perCommitmentGasLimit.
            (bool success,) = self.inner[i].relation.address.staticcall{gas: perCommitmentGasLimit}(
                abi.encodeWithSelector(self.inner[i].relation.selector, assignment.value)
            );

            if (!success) {
                return false;
            }
        }
        return true;
    }

    /// @dev Wraps a Commitment in a CommitmentSet.
    /// @param commitment The Commitment to wrap.
    /// @return  set CommitmentSet containing the given Commitment.
    function wrap(Commitment memory commitment) public pure returns (CommitmentSet memory set) {
        set = CommitmentSet(new Commitment[](1));
        set.inner[0] = commitment;
    }
}
