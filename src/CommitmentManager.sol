// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./lib/types.sol";

contract CommitmentManager {
    uint256 public immutable ACCOUNT_COMMITMENT_GAS_LIMIT;

    mapping(address => Commitment) internal _commitments;

    constructor(uint256 accountCommitmentGasLimit) {
        ACCOUNT_COMMITMENT_GAS_LIMIT = accountCommitmentGasLimit;
    }

    function makeNewCommitment(address indicatorAddress, bytes4 indicatorSelector) public {
        function (Assignment memory) view external returns (uint256)[] memory indicator =
            new function (Assignment memory) view external returns (uint256)[](1);

        function (Assignment memory) view external returns (uint256) firstIndicator = indicator[0];

        assembly {
            firstIndicator.address := indicatorAddress
            firstIndicator.selector := indicatorSelector
        }
        Commitment memory commitment = Commitment({indicator: indicator});
        _commitments[msg.sender].concat(commitment);
    }

    function isAccountCommitmentSatisfied(address account, bytes32 target, bytes memory value)
        external
        view
        returns (bool)
    {
        Assignment memory assignment = Assignment({target: target, value: value});
        return _commitments[account].isCommitmentSatisfiedByAssignment(assignment, ACCOUNT_COMMITMENT_GAS_LIMIT);
    }
}
