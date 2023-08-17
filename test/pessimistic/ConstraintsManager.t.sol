// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {PessimisticConstraintsManager as ConstraintsManager} from "../../src/PessimisticConstraintsManager.sol";

import {ConstraintsManagerHandler as Handler} from "./ConstraintsManagerHandler.sol";

contract ConstraintsManagerInvariants is Test {
    ConstraintsManager public constraintsManager;
    Handler public handler;

    function setUp() public {
        constraintsManager = new ConstraintsManager(address(this));
        handler = new Handler(constraintsManager);

        bytes4[] memory selectors = new bytes4[](4);
        selectors[0] = Handler.addConstraint.selector;
        selectors[1] = Handler.areConstraintsAllSatisfied.selector;
        selectors[2] = Handler.getConstraints.selector;
        selectors[3] = Handler.countConstraints.selector;

        targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));

        targetContract(address(handler));
    }

    function invariant_gasUsed_areConstraintsAllSatisfied() public {
        assertLe(handler.ghost_gasUsed_areConstraintsAllSatisfied(), constraintsManager.CONSTRAINTS_GAS_LIMIT());
    }

    function invariant_callSummary() public view {
        handler.callSummary();
    }
}
