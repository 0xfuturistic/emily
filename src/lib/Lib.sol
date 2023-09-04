// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./types.sol";

/// @title Commitment Library
/// @dev A library for handling commitments.
library CommitmentsLib {
    /// @notice Checks if commitments are satisfied by a value.
    /// @param commitments An array of commitments.
    /// @param value The value to check against the commitments.
    /// @return A boolean indicating whether the array of commitments is satisfied by the value.
    function areCommitmentsSatisfiedByValue(Commitment[] memory commitments, bytes calldata value)
        public
        view
        returns (bool)
    {
        for (uint256 i = 0; i < commitments.length; i++) {
            if (isFinalized(commitments[i])) {
                (bool success, bytes memory data) = commitments[i].indicatorFunction.address.staticcall(
                    abi.encodeWithSelector(commitments[i].indicatorFunction.selector, value)
                );

                if (!success || abi.decode(data, (uint256)) != 1) {
                    return false;
                }
            }
        }
        return true;
    }

    /// @notice Checks if a commitment is finalized.
    /// @param commitments The commitment to check.
    /// @return finalized A boolean indicating whether the commitment is finalized.
    function isFinalized(Commitment memory commitments) public view returns (bool finalized) {
        // We take a commitment as finalized if it was made more than an epoch ago, where an epoch is 7 minutes (consensus)
        // Ideally, we'll use something more robust, but this is good enough for now.
        return block.timestamp - commitments.timestamp > 7 minutes;
    }
}
