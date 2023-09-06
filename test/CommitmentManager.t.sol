// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import "../src/lib/types.sol";
import {CommitmentManager} from "../src/CommitmentManager.sol";
import {CommitmentManagerHandler as Handler} from "./handlers/CommitmentManagerHandler.sol";

contract CommitmentManagerTest is Test {
    using CommitmentsLib for Commitment[];

    CommitmentManager public manager;
    Handler public handler;

    function setUp() public {
        manager = new CommitmentManager(10000);
        handler = new Handler(manager);

        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = handler.makeCommitment.selector;
        selectors[1] = handler.areAccountCommitmentsSatisfiedByValue.selector;

        targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));

        targetContract(address(handler));
    }

    function test_MakeCommitment(
        address actor,
        bytes32 target,
        address indicatorFunctionAddress,
        bytes4 indicatorFunctionSelector
    ) public {
        vm.prank(actor);
        manager.makeCommitment(target, indicatorFunctionAddress, indicatorFunctionSelector);

        Commitment[] memory actorCommitments = manager.getCommitments(actor, target);

        assertEq(actorCommitments.length, 1);

        function (bytes memory) external view returns (uint256) indicatorFunction;
        assembly {
            indicatorFunction.address := indicatorFunctionAddress
            indicatorFunction.selector := indicatorFunctionSelector
        }

        assertEq(actorCommitments[actorCommitments.length - 1].indicatorFunction.address, indicatorFunction.address);
        assertEq(actorCommitments[actorCommitments.length - 1].indicatorFunction.selector, indicatorFunction.selector);
    }

    function invariant_areAccountCommitmentsSatisfiedByValue_satisfied() public {
        (address account, bytes32 target, bytes memory value, uint256 upToTimestamp) =
            handler.ghost_satisfiedAssignment();

        Commitment[] memory commitments = manager.getCommitments(account, target);

        for (uint256 i = 0; i < commitments.length; i++) {
            if (CommitmentsLib.isFinalizedByTimestamp(commitments[i], upToTimestamp)) {
                (bool success, bytes memory data) = commitments[i].indicatorFunction.address.staticcall(
                    abi.encodeWithSelector(commitments[i].indicatorFunction.selector, value)
                );

                assertTrue(success);
                assertEq(abi.decode(data, (uint256)), 1);
            }
        }
    }

    function invariant_areAccountCommitmentsSatisfiedByValue_unsatisfied() public {
        (address account, bytes32 target, bytes memory value, uint256 upToTimestamp) =
            handler.ghost_unsatisfiedAssignment();

        Commitment[] memory commitments = manager.getCommitments(account, target);

        for (uint256 i = 0; i < commitments.length; i++) {
            if (CommitmentsLib.isFinalizedByTimestamp(commitments[i], upToTimestamp)) {
                (bool success, bytes memory data) = commitments[i].indicatorFunction.address.staticcall(
                    abi.encodeWithSelector(commitments[i].indicatorFunction.selector, value)
                );

                if (!success || abi.decode(data, (uint256)) != 1) {
                    return;
                }
            }
        }
        if (commitments.length > 0) {
            assertFalse(true);
        }
    }

    function invariant_callSummary() public view {
        handler.callSummary();
    }
}
