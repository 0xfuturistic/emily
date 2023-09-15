// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import {console} from "forge-std/console.sol";
import {CommitmentPBS} from "../../src/samples/CommitmentPBS.sol";

import "../../src/lib/types.sol";

contract CommitmentPBSHandler is CommonBase, StdCheats, StdUtils {
    CommitmentPBS public pbs;

    bytes public ghost_indicatorData;
    uint256 public ghost_indicatorOutcome;

    mapping(bytes32 => uint256) public calls;

    address[] public actors;
    address internal currentActor;

    modifier createActor() {
        currentActor = msg.sender;
        actors.push(msg.sender);
        _;
    }

    modifier useActor(uint256 actorIndexSeed) {
        currentActor = actors[bound(actorIndexSeed, 0, actors.length - 1)];
        vm.startPrank(currentActor);
        _;
        vm.stopPrank();
    }

    modifier countCall(bytes32 key) {
        calls[key]++;
        _;
    }

    constructor(CommitmentPBS pbs_) {
        pbs = pbs_;
    }

    function commitToBuilder(address builder, uint64 blockNumber) public createActor countCall("commitToBuilder") {
        pbs.commitToBuilder(builder, blockNumber);
    }

    function commitmentIndicator(uint256 actorIndexSeed, uint64 blockNumber, address builder, bytes memory body)
        public
        useActor(actorIndexSeed)
        countCall("commitmentIndicator")
        returns (uint256)
    {
        ghost_indicatorData = abi.encode(
            CommitmentPBS.SignedBeaconBlock({
                block_: CommitmentPBS.BeaconBlock({
                    BlockNumber: blockNumber,
                    Proposer: currentActor,
                    Builder: builder,
                    Body: body
                }),
                signature: bytes32(0)
            })
        );
        ghost_indicatorOutcome = pbs.commitmentIndicator(ghost_indicatorData);

        return ghost_indicatorOutcome;
    }

    function callSummary() external view {
        console.log("Call summary:");
        console.log("-------------------");
        console.log("commitToBuilder", calls["commitToBuilder"]);
        console.log("commitmentIndicator", calls["commitmentIndicator"]);
        console.log("-------------------");
    }
}
