// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import {console} from "forge-std/console.sol";
import {CommitmentManager} from "../../src/CommitmentManager.sol";

import "../../src/lib/types.sol";

contract CommitmentManagerHandler is CommonBase, StdCheats, StdUtils {
    CommitmentManager public manager;

    function (bytes memory) external view returns (uint256) public ghost_indicatorFunction;

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

    constructor(CommitmentManager manager_) {
        manager = manager_;
    }

    function makeCommitment(bytes32 target, address indicatorFunctionAddress, bytes4 indicatorFunctionSelector)
        public
        createActor
        countCall("makeCommitment")
    {
        manager.makeCommitment(target, indicatorFunctionAddress, indicatorFunctionSelector);
        Commitment[] memory actorCommitments = manager.getCommitments(currentActor, target);
        ghost_indicatorFunction = actorCommitments[actorCommitments.length - 1].indicatorFunction;
    }

    function areAccountCommitmentsSatisfiedByValue(
        uint256 actorSeed,
        address account,
        bytes32 target,
        bytes calldata value
    ) public useActor(actorSeed) countCall(keccak256("areAccountCommitmentsSatisfiedByValue")) {
        manager.areAccountCommitmentsSatisfiedByValue(account, target, value);
    }

    function callSummary() external view {
        console.log("Call summary:");
        console.log("-------------------");
        console.log("makeCommitment", calls["makeCommitment"]);
        console.log("areAccountCommitmentsSatisfiedByValue", calls[keccak256("areAccountCommitmentsSatisfiedByValue")]);
        console.log("-------------------");
    }
}
