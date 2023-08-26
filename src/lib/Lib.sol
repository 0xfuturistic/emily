// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./types.sol";

/// @title Commitment Library
/// @dev A library for Commitment.
library CommitmentLib {
    /// @dev Returns a commitment to no constraints.
    /// @return identityCommitment A commitment to no constraints.
    function identity() public pure returns (Commitment memory identityCommitment) {
        identityCommitment = Commitment(new Constraint[](0));
    }

    /// @dev Adds two commitments together.
    /// @param commitmentLeft Commitment to add.
    /// @param commitmentRight Commitment to add.
    function add(Commitment storage commitmentLeft, Commitment memory commitmentRight) public {
        for (uint256 i = 0; i < commitmentRight.inner.length; i++) {
            commitmentLeft.inner.push(commitmentRight.inner[i]);
        }
    }

    function isSolution(Commitment memory commitment, Assignment memory assignment, uint256 totalGasLimit)
        public
        view
        returns (bool)
    {
        return isSolution(commitment.inner, assignment, totalGasLimit);
    }

    /// @dev Checks if a compound assignment is a solution to a set of constraints.
    /// @param constraintSet Constraint set
    /// @param assignment Instance
    /// @param totalGasLimit Gas limit for evaluating the constraint's
    ///                      relation at the assignment.
    /// @return True if and only if the assignment is a
    ///         solution to the constraint under the given
    ///         gas limit.
    function isSolution(Constraint[] memory constraintSet, Assignment memory assignment, uint256 totalGasLimit)
        public
        view
        returns (bool)
    {
        uint256 perConstraintGasLimit = totalGasLimit / constraintSet.length;
        for (uint256 i = 0; i < constraintSet.length; i++) {
            if (!isSatisfied(constraintSet[i], assignment, perConstraintGasLimit)) {
                return false;
            }
        }
        return true;
    }

    /// @dev Checks if a compound assignment satisfies a constraint.
    /// @param constraint Constraint
    /// @param assignment Assignment
    /// @param gasLimit Gas limit for evaluating the constraint's
    ///                 relation at the assignment.
    /// @return success True if and only if the assignment is a
    ///                 solution to the constraint under the given
    ///                 gas limit.
    function isSatisfied(Constraint memory constraint, Assignment memory assignment, uint256 gasLimit)
        public
        view
        returns (bool)
    {
        if (constraint.scope != assignment.target) return true;

        (bool success, bytes memory data) = constraint.relation.address.staticcall{gas: gasLimit}(
            abi.encodeWithSelector(constraint.relation.selector, assignment.value)
        );

        if (success && abi.decode(data, (bool)) == true) {
            return true;
        } else {
            return false;
        }
    }
}
