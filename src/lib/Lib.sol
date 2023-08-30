// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./types.sol";

/// @title Commitment Library
/// @dev A library for handling commitments.
library CommitmentsLib {
    /// @notice Checks if a given array of commitments is satisfied at a given value.
    /// @param commitments An array of commitments to check.
    /// @param value The value to provide to the commitments.
    /// @return A boolean indicating whether all commitments are satisfied by the given value.
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

    /// @notice Checks if a given commitment is finalized.
    /// @param commitments The commitment to check.
    /// @return finalized A boolean indicating whether the commitment is finalized.
    function isFinalized(Commitment memory commitments) public view returns (bool finalized) {
        return block.timestamp - commitments.timestamp > 7 minutes;
    }
}
