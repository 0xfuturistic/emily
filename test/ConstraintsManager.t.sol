// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2, console} from "forge-std/Test.sol";
import {ConstraintsManagerHandler as Handler} from "./ConstraintsManagerHandler.sol";
import {ConstraintsManager} from "../src/ConstraintsManager.sol";
import {UserOperation} from "erc4337/core/BaseAccount.sol";

import "../src/lib/types.sol";

contract ConstraintsManagerTest is Test {
    ConstraintsManager public constraintsManager;
    Handler public handler;

    function setUp() public {
        constraintsManager = new ConstraintsManager(address(this));
        handler = new Handler(constraintsManager, address(this));
        targetContract(address(handler));
    }

    function test_addConstraint(address contractAddr, bytes4 selector) public {
        handler.addConstraint(contractAddr, selector);
    }

    function test_areConstraintsAllSatisfied(bytes memory input, uint256 absoluteGasLimit) public {
        handler.areConstraintsAllSatisfied(input, absoluteGasLimit);
    }

    function test_getConstraints() public view returns (Constraint[] memory constraints_) {
        constraints_ = handler.getConstraints();
    }

    function test_countConstraints() public view returns (uint256 count) {
        count = handler.countConstraints();
    }
}
