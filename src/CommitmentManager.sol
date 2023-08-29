// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./lib/types.sol";

contract CommitmentManager {
    uint256 public immutable ACCOUNT_COMMITMENTS_GAS_LIMIT;

    mapping(address => Commitment[]) internal _commitments;

    constructor(uint256 accountCommitmentsGasLimit) {
        ACCOUNT_COMMITMENTS_GAS_LIMIT = accountCommitmentsGasLimit;
    }

    function makeNewCommitment(address indicatorAddress, bytes4 indicatorSelector) public {
        function (Assignment memory) view external returns (uint256) indicator;
        assembly {
            indicator.address := indicatorAddress
            indicator.selector := indicatorSelector
        }
        Commitment memory commitment = Commitment({indicator: indicator});
        _commitments[msg.sender].push(commitment);
    }

    function areAccountCommitmentsSatisfied(address account, bytes32 target, bytes memory value)
        external
        view
        returns (bool)
    {
        Assignment memory assignment = Assignment({target: target, value: value});
        return CommitmentsLib.areCommitmentsSatisfiedByAssignment(
            _commitments[account], assignment, ACCOUNT_COMMITMENTS_GAS_LIMIT
        );
    }
}
