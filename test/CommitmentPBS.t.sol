// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import "../src/lib/types.sol";
import {CommitmentPBS} from "../src/samples/CommitmentPBS.sol";
import {CommitmentManager} from "../src/CommitmentManager.sol";
import {CommitmentPBSHandler as Handler} from "./handlers/CommitmentPBSHandler.sol";

contract CommitmentPBSTest is Test {
    CommitmentPBS public pbs;
    CommitmentManager public manager;
    Handler public handler;

    function setUp() public {
        pbs = new CommitmentPBS();
        pbs.setCommitmentManager(address(manager = new CommitmentManager(10000, 7 minutes)));
        handler = new Handler(pbs);

        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = handler.commitToBuilder.selector;
        selectors[1] = handler.commitmentIndicator.selector;

        targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));

        targetContract(address(handler));
    }

    function invariant_commitmentIndicatorConsistency() public {
        bytes memory ghost_indicatorData = handler.ghost_indicatorData();

        if (ghost_indicatorData.length == 0) {
            return;
        }

        CommitmentPBS.BeaconBlock memory beaconBlock =
            abi.decode(ghost_indicatorData, (CommitmentPBS.SignedBeaconBlock)).block_;

        // make commitment in manager
        bytes32 target = keccak256(abi.encode(beaconBlock.BlockNumber));
        vm.prank(beaconBlock.Proposer);
        manager.makeCommitment(target, address(handler), handler.commitmentIndicator.selector);

        assertEq(
            handler.ghost_indicatorOutcome() == 1 ? true : false,
            pbs.screen(beaconBlock.Proposer, target, ghost_indicatorData)
        );
    }

    function invariant_callSummary() public view {
        handler.callSummary();
    }
}
