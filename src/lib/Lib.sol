// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./types.sol";

/// @title Commitment Library
/// @dev A library for handling commitments.
library CommitmentsLib {
    function areCommitmentsSatisfiedByAssignment(
        Commitment[] memory commitments,
        Assignment memory assignment,
        uint256 gasLimit
    ) public view returns (bool) {
        for (uint256 i = 0; i < commitments.length; i++) {
            (bool success, bytes memory data) = commitments[i].indicator.address.staticcall{gas: gasLimit}(
                abi.encodeWithSelector(commitments[i].indicator.selector, assignment)
            );

            if (!success || abi.decode(data, (uint256)) != 1) {
                return false;
            }
        }
        return true;
    }
}
