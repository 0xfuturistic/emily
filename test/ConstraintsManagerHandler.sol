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
    address public constraintsAdder;

    mapping(bytes32 => uint256) public calls;

    modifier countCall(bytes32 key) {
        calls[key]++;
        _;
    }

    constructor(ConstraintsManager constraintsManager_, address constraintsAdder_) {
        constraintsManager = constraintsManager_;

        constraintsAdder = constraintsAdder_;
    }

    function addConstraint(address contractAddr, bytes4 selector) external countCall("addConstraint") {
        vm.prank(constraintsAdder);
        constraintsManager.addConstraint(contractAddr, selector);
    }

    function areConstraintsAllSatisfied(bytes memory input, uint256 absoluteGasLimit)
        external
        countCall("areConstraintsAllSatisfied")
        returns (bool satisfied)
    {
        uint256 gasBefore = gasleft();
        satisfied = constraintsManager.areConstraintsAllSatisfied(input, absoluteGasLimit);
        uint256 gasAfter = gasleft();

        if (constraintsManager.countConstraints() > 0) {
            require(absoluteGasLimit >= gasBefore - gasAfter, "AccountHandler: validateUserOp gas usage too high");
        }
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
