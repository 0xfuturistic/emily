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

    function makeCommitment(bytes32 target, address indicatorFunAddress, bytes4 indicatorFunSelector) external {
        function (bytes memory) view external returns (uint256) indicatorFun;
        assembly {
            indicatorFun.address := indicatorFunAddress
            indicatorFun.selector := indicatorFunSelector
        }
        Commitment memory commitment = Commitment({indicator: indicatorFun});
        commitments[msg.sender][target].push(commitment);
    }

    function areAccountCommitmentsSatisfied(address account, bytes32 target, bytes calldata value)
        external
        view
        returns (bool)
    {
        (bool success,) = address(this).staticcall{gas: ACCOUNT_COMMITMENTS_GAS_LIMIT}(
            abi.encodeWithSelector(this.areCommitmentsSatisfied.selector, commitments[account][target], value)
        );

        return success;
    }

    function areCommitmentsSatisfied(Commitment[] memory commitments_, bytes calldata value)
        public
        view
        returns (bool)
    {
        return commitments_.areCommitmentsSatisfied(value);
    }
}
