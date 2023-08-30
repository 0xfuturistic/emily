// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./lib/types.sol";

/// @title CommitmentManager
/// @dev A contract that manages commitments made by accounts to specific targets.
contract CommitmentManager {
    using CommitmentsLib for Commitment[];

    /// @dev The gas limit for the `areAccountCommitmentsSatisfiedByValue` function.
    uint256 public immutable ACCOUNT_COMMITMENTS_GAS_LIMIT;

    /// @dev A mapping of account addresses to a mapping of target hashes to an array of commitments.
    mapping(address => mapping(bytes32 => Commitment[])) public commitments;

    /// @dev Constructor function that sets the `ACCOUNT_COMMITMENTS_GAS_LIMIT`.
    /// @param accountCommitmentsGasLimit The gas limit for the `areAccountCommitmentsSatisfiedByValue` function.
    constructor(uint256 accountCommitmentsGasLimit) {
        ACCOUNT_COMMITMENTS_GAS_LIMIT = accountCommitmentsGasLimit;
    }

    /// @dev Function that creates a new commitment for the calling account and target.
    /// @param target The target hash for the commitment.
    /// @param indicatorFunctionAddress The address of the indicator function of the commitment.
    /// @param indicatorFunctionSelector The selector of the indicator function of the commitment.
    function makeCommitment(bytes32 target, address indicatorFunctionAddress, bytes4 indicatorFunctionSelector)
        external
    {
        function (bytes memory) view external returns (uint256) indicatorFunction;
        assembly {
            indicatorFunction.address := indicatorFunctionAddress
            indicatorFunction.selector := indicatorFunctionSelector
        }
        Commitment memory commitment = Commitment({timestamp: block.timestamp, indicatorFunction: indicatorFunction});
        commitments[msg.sender][target].push(commitment);
    }

    /// @dev Function that checks if the commitments made by an account to a target are satisfied by a given value.
    /// @param account The account address.
    /// @param target The target hash.
    /// @param value The value to check against the commitments.
    /// @return A boolean indicating whether the commitments are satisfied by the value.
    function areAccountCommitmentsSatisfiedByValue(address account, bytes32 target, bytes calldata value)
        external
        view
        returns (bool)
    {
        (bool success, bytes memory data) = address(this).staticcall{gas: ACCOUNT_COMMITMENTS_GAS_LIMIT}(
            abi.encodeWithSelector(this.areCommitmentsSatisfiedByValue.selector, commitments[account][target], value)
        );

        return success && abi.decode(data, (bool));
    }

    /// @dev Function that checks if an array of commitments is satisfied by a given value.
    /// @param commitments_ The array of commitments.
    /// @param value The value to check against the commitments.
    /// @return A boolean indicating whether the commitments are satisfied by the value.
    function areCommitmentsSatisfiedByValue(Commitment[] memory commitments_, bytes calldata value)
        public
        view
        returns (bool)
    {
        return commitments_.areCommitmentsSatisfiedByValue(value);
    }

    /// @dev Function that returns an array of commitments made by an account to a target.
    /// @param account The account address.
    /// @param target The target hash.
    /// @return An array of commitments.
    function getCommitments(address account, bytes32 target) external view returns (Commitment[] memory) {
        return commitments[account][target];
    }
}
