// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./types.sol";

/// @title Commitment Library
/// @dev A library for handling Commitments.
library CommitmentLib {
    function concat(Commitment storage commitmentLeft, Commitment memory commitmentRight) public {
        for (uint256 i = 0; i < commitmentRight.indicator.length; i++) {
            commitmentLeft.indicator.push(commitmentRight.indicator[i]);
        }
    }

    function isCommitmentSatisfiedByAssignment(
        Commitment memory commitment,
        Assignment memory assignment,
        uint256 gasLimit
    ) public view returns (bool) {
        for (uint256 i = 0; i < commitment.indicator.length; i++) {
            (bool success, bytes memory data) = commitment.indicator[i].address.staticcall{gas: gasLimit}(
                abi.encodeWithSelector(commitment.indicator[i].selector, assignment)
            );

            if (!success || abi.decode(data, (uint256)) != 1) {
                return false;
            }
        }
        return true;
    }
}
