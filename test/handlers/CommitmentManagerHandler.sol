// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import {console} from "forge-std/console.sol";
import {CommitmentManager} from "../../src/CommitmentManager.sol";

import "../../src/lib/types.sol";

contract CommitmentManagerHandler is CommonBase, StdCheats, StdUtils {
    CommitmentManager public manager;

    mapping(bytes32 => uint256) public calls;

    address[] public actors;
    address internal currentActor;

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

    function makeCommitment(
        uint256 actorIndexSeed,
        bytes32 target,
        address indicatorFunctionAddress,
        bytes4 indicatorFunctionSelector
    ) public useActor(actorIndexSeed) countCall("makeCommitment") {
        manager.makeCommitment(target, indicatorFunctionAddress, indicatorFunctionSelector);
    }

    function areAccountCommitmentsSatisfiedByValue(address account, bytes32 target, bytes calldata value)
        public
        countCall(keccak256("areAccountCommitmentsSatisfiedByValue"))
        returns (bool)
    {
        return manager.areAccountCommitmentsSatisfiedByValue(account, target, value);
    }

    function areCommitmentsSatisfiedByValue(Commitment[] memory commitments_, bytes calldata value)
        public
        countCall("areCommitmentsSatisfiedByValue")
        returns (bool)
    {
        return manager.areCommitmentsSatisfiedByValue(commitments_, value);
    }

    function callSummary() public view {
        console.log("Call summary:");
        console.log("-------------------");
        console.log("makeCommitment", calls["makeCommitment"]);
        console.log("areAccountCommitmentsSatisfiedByValue", calls[keccak256("areAccountCommitmentsSatisfiedByValue")]);
        console.log("areCommitmentsSatisfiedByValue", calls["areCommitmentsSatisfiedByValue"]);
        console.log("-------------------");
    }
}
