// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./types.sol";

/// @title Commitment Library
/// @dev A library for handling commitments.
library CommitmentsLib {
    function areCommitmentsSatisfiedByValue(Commitment[] memory commitments, bytes calldata value)
        public
        view
        returns (bool)
    {
        for (uint256 i = 0; i < commitments.length; i++) {
            (bool success, bytes memory data) = commitments[i].indicator.address.staticcall(
                abi.encodeWithSelector(commitments[i].indicator.selector, value)
            );

            if (!success || abi.decode(data, (uint256)) != 1) {
                return false;
            }
        }
        return true;
    }
}
