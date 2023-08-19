// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import "../src/lib/types.sol";
import {IntentManager} from "../src/IntentManager.sol";
import {IntentManagerHandler as Handler} from "./handlers/IntentManagerHandler.sol";

contract IntentManagerTest is Test {
    IntentManager public intentManager;
    Handler public handler;

    function setUp() public {
        intentManager = new IntentManager(address(this));
        handler = new Handler(intentManager);

        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = Handler.setConstraint.selector;

        targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));

        targetContract(address(handler));
    }

    function invariant_callSummary() public view {
        handler.callSummary();
    }

    function test_setConstraint(Intent intent, address newAddress, uint256 newSelector) public {
        function (bytes memory) external view constraint;
        assembly {
            constraint.selector := newSelector
            constraint.address := newAddress
        }
        //if (msg.sender != intentManager.owner()) vm.expectRevert();
        intentManager.setConstraint(intent, constraint);
    }
}
