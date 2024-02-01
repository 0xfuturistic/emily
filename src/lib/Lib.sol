// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./types.sol";

/// @title Commitment Library
/// @dev A library for handling commitments.
library CommitmentsLib {
    /// @notice Checks if commitments are satisfied by a value.
    /// @param commitments An array of commitments.
    /// @param value The value to check against the commitments.
    /// @param upToTimestamp The timestamp to check against.
    /// @param finalization The amount of seconds required to pass before a commitment is finalized.
    /// @return A boolean indicating whether the array of commitments is satisfied by the value.
    function areCommitmentsSatisfiedByValue(
        Commitment[] memory commitments,
        bytes calldata value,
        uint256 upToTimestamp,
        uint256 finalization
    ) public view returns (bool) {
        for (uint256 i = 0; i < commitments.length; i++) {
            if (isFinalizedByTimestamp(commitments[i], upToTimestamp, finalization)) {
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
    /// @param commitment The commitment to check.
    /// @param timestamp The timestamp to check against.
    /// @param finalization The amount of seconds required to pass before a commitment is finalized.
    /// @return finalized A boolean indicating whether the commitment is finalized.
    function isFinalizedByTimestamp(Commitment memory commitment, uint256 timestamp, uint256 finalization)
        public
        pure
        returns (bool finalized)
    {
        // We take a commitment as finalized if it was made more than an epoch ago, where an epoch is 7 minutes (consensus)
        // Ideally, we'll use something more robust.
        return timestamp - commitment.timestamp > finalization;
    }
}
