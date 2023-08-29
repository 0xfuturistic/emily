// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./lib/types.sol";

contract CommitmentManager {
    uint256 public immutable ACCOUNT_COMMITMENTS_GAS_LIMIT;

    mapping(address => Commitment[]) public commitments;

    constructor(uint256 accountCommitmentsGasLimit) {
        ACCOUNT_COMMITMENTS_GAS_LIMIT = accountCommitmentsGasLimit;
    }

    function makeNewCommitment(address indicatorAddress, bytes4 indicatorSelector) external {
        function (Assignment memory) view external returns (uint256) indicator;
        assembly {
            indicator.address := indicatorAddress
            indicator.selector := indicatorSelector
        }
        Commitment memory commitment = Commitment({indicator: indicator});
        commitments[msg.sender].push(commitment);
    }

    function areAccountCommitmentsSatisfied(address account, bytes32 target, bytes memory value)
        external
        view
        returns (bool)
    {
        Assignment memory assignment = Assignment({target: target, value: value});

        (bool success,) = address(this).staticcall{gas: ACCOUNT_COMMITMENTS_GAS_LIMIT}(
            abi.encodeWithSelector(this.areCommitmentsSatisfiedByAssignment.selector, commitments[account], assignment)
        );

        return success;
    }

    function areCommitmentsSatisfiedByAssignment(Commitment[] memory commitments_, Assignment memory assignment)
        public
        view
        returns (bool)
    {
        return CommitmentsLib.areCommitmentsSatisfiedByAssignment(commitments_, assignment);
    }
}
