// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import "../src/lib/types.sol";
import {CommitmentManager} from "../src/CommitmentManager.sol";
import {CommitmentManagerHandler as Handler} from "./handlers/CommitmentManagerHandler.sol";

contract CommitmentManagerTest is Test {
    CommitmentManager public manager;
    Handler public handler;

    function setUp() public {
        manager = new CommitmentManager(10000);
        handler = new Handler(manager);

        bytes4[] memory selectors = new bytes4[](4);
        selectors[0] = Handler.callSummary.selector;
        selectors[1] = Handler.makeCommitment.selector;
        selectors[2] = Handler.areAccountCommitmentsSatisfiedByValue.selector;
        selectors[3] = Handler.areCommitmentsSatisfiedByValue.selector;

        targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));

        targetContract(address(handler));
    }

    function testMakeCommitment(bytes32 target, address indicatorFunctionAddress, bytes4 indicatorFunctionSelector)
        public
    {
        vm.prank(msg.sender);
        manager.makeCommitment(target, indicatorFunctionAddress, indicatorFunctionSelector);

        function (bytes memory) external view returns (uint256) indicatorFunction;
        assembly {
            indicatorFunction.address := indicatorFunctionAddress
            indicatorFunction.selector := indicatorFunctionSelector
        }

        assertEq(manager.getCommitments(msg.sender, target).length, 1);
        assertEq(manager.getCommitments(msg.sender, target)[0].indicatorFunction.address, indicatorFunction.address);
        assertEq(manager.getCommitments(msg.sender, target)[0].indicatorFunction.selector, indicatorFunction.selector);
    }

    function invariant_callSummary() public {
        assertEq(handler.calls("makeCommitment"), 0);
        assertEq(handler.calls("areAccountCommitmentsSatisfiedByValue"), 0);
        assertEq(handler.calls("areCommitmentsSatisfiedByValue"), 0);
    }
}
