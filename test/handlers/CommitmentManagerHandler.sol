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

    struct Assignment {
        address account;
        bytes32 target;
        bytes value;
        uint256 upToTimestamp;
    }

    Assignment public ghost_satisfiedAssignment;
    Assignment public ghost_unsatisfiedAssignment;

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
    }

    function areAccountCommitmentsSatisfiedByValue(
        address account,
        bytes32 target,
        bytes calldata value,
        uint256 upToTimestamp
    ) public countCall(keccak256("areAccountCommitmentsSatisfiedByValue")) returns (bool) {
        if (manager.areAccountCommitmentsSatisfiedByValue(account, target, value, upToTimestamp)) {
            ghost_satisfiedAssignment =
                Assignment({account: account, target: target, value: value, upToTimestamp: upToTimestamp});
            return true;
        } else {
            ghost_unsatisfiedAssignment =
                Assignment({account: account, target: target, value: value, upToTimestamp: upToTimestamp});
            return false;
        }
    }

    function areCommitmentsSatisfiedByValue(
        Commitment[] memory commitments_,
        bytes calldata value,
        uint256 upToTimestamp
    ) public countCall("areCommitmentsSatisfiedByValue") returns (bool) {
        return manager.areCommitmentsSatisfiedByValue(commitments_, value, upToTimestamp);
    }

    function getCommitments(address account, bytes32 target)
        public
        countCall("getCommitments")
        returns (Commitment[] memory)
    {
        return manager.getCommitments(account, target);
    }

    function callSummary() external view {
        console.log("Call summary:");
        console.log("-------------------");
        console.log("makeCommitment", calls["makeCommitment"]);
        console.log("areAccountCommitmentsSatisfiedByValue", calls[keccak256("areAccountCommitmentsSatisfiedByValue")]);
        console.log("areCommitmentsSatisfiedByValue", calls["areCommitmentsSatisfiedByValue"]);
        console.log("getCommitments", calls["getCommitments"]);
        console.log("-------------------");
    }
}
