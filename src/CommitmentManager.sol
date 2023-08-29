// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./lib/types.sol";

contract CommitmentManager {
    using CommitmentsLib for Commitment[];

    uint256 public immutable ACCOUNT_COMMITMENTS_GAS_LIMIT;

    mapping(address => mapping(bytes32 => Commitment[])) public commitments;

    constructor(uint256 accountCommitmentsGasLimit) {
        ACCOUNT_COMMITMENTS_GAS_LIMIT = accountCommitmentsGasLimit;
    }

    function makeCommitment(bytes32 target, address indicatorFunctionAddress, bytes4 indicatorFunctionSelector)
        external
    {
        function (bytes memory) view external returns (uint256) indicatorFunction;
        assembly {
            indicatorFunction.address := indicatorFunctionAddress
            indicatorFunction.selector := indicatorFunctionSelector
        }
        Commitment memory commitment = Commitment({indicatorFunction: indicatorFunction});
        commitments[msg.sender][target].push(commitment);
    }

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

    function areCommitmentsSatisfiedByValue(Commitment[] memory commitments_, bytes calldata value)
        public
        view
        returns (bool)
    {
        return commitments_.areCommitmentsSatisfiedByValue(value);
    }

    function getCommitments(address account, bytes32 target) external view returns (Commitment[] memory) {
        return commitments[account][target];
    }
}
