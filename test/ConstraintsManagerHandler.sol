// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2, console} from "forge-std/Test.sol";
import {UserOperation} from "erc4337/core/BaseAccount.sol";
import {ConstraintsManager} from "../src/ConstraintsManager.sol";

import "../src/lib/types.sol";

contract ConstraintsManagerHandler is Test {
    ConstraintsManager public constraintsManager;
    address public constraintsAdder;

    constructor(ConstraintsManager constraintsManager_, address constraintsAdder_) {
        constraintsManager = constraintsManager_;
        constraintsAdder = constraintsAdder_;
    }

    function addConstraint(address contractAddr, bytes4 selector) external virtual {
        vm.prank(constraintsAdder);
        constraintsManager.addConstraint(contractAddr, selector);
    }

    function areConstraintsAllSatisfied(bytes memory input, uint256 absoluteGasLimit)
        external
        virtual
        returns (bool satisfied)
    {
        uint256 gasBefore = gasleft();
        satisfied = constraintsManager.areConstraintsAllSatisfied(input, absoluteGasLimit);
        uint256 gasAfter = gasleft();

        if (constraintsManager.countConstraints() > 0) {
            require(absoluteGasLimit >= gasBefore - gasAfter, "AccountHandler: validateUserOp gas usage too high");
        }
    }

    function getConstraints() public view returns (Constraint[] memory constraints_) {
        constraints_ = constraintsManager.getConstraints();
    }

    function countConstraints() public view returns (uint256 count) {
        count = constraintsManager.countConstraints();
    }
}
