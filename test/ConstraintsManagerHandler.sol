// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import {console} from "forge-std/console.sol";
import {UserOperation} from "erc4337/core/BaseAccount.sol";
import {ConstraintsManager} from "../src/ConstraintsManager.sol";

import "../src/lib/types.sol";

contract ConstraintsManagerHandler is CommonBase, StdCheats, StdUtils {
    ConstraintsManager public constraintsManager;

    uint256 public ghost_gasUsed_areConstraintsAllSatisfied;

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

    constructor(ConstraintsManager constraintsManager_) {
        constraintsManager = constraintsManager_;
    }

    function addConstraint(address contractAddr, bytes4 selector, uint256 actorIndexSeed)
        external
        countCall("addConstraint")
        useActor(actorIndexSeed)
        returns (Constraint memory constraint)
    {
        if (!constraintsManager.hasRole(constraintsManager.CONSTRAINTS_ADDER_ROLE(), currentActor)) vm.expectRevert();
        constraint = constraintsManager.addConstraint(contractAddr, selector);
    }

    function areConstraintsAllSatisfied(bytes memory input)
        external
        countCall("areConstraintsAllSatisfied")
        returns (bool satisfied)
    {
        // gas metering for areConstraintsAllSatisfied
        uint256 gasBefore = gasleft();
        constraintsManager.areConstraintsAllSatisfied(input);
        ghost_gasUsed_areConstraintsAllSatisfied = gasBefore - gasleft();
        console.log("gas used in areConstraintsAllSatisfied:", ghost_gasUsed_areConstraintsAllSatisfied);

        // actual call
        satisfied = constraintsManager.areConstraintsAllSatisfied(input);
    }

    function getConstraints() external countCall("getConstraints") returns (Constraint[] memory constraints_) {
        constraints_ = constraintsManager.getConstraints();
    }

    function countConstraints() external countCall("countConstraints") returns (uint256 count) {
        count = constraintsManager.countConstraints();
    }

    function callSummary() external view {
        console.log("Call summary:");
        console.log("-------------------");
        console.log("addConstraint", calls["addConstraint"]);
        console.log("areConstraintsAllSatisfied", calls["areConstraintsAllSatisfied"]);
        console.log("getConstraints", calls["getConstraints"]);
        console.log("countConstraints", calls["countConstraints"]);
        console.log("-------------------");
    }
}
