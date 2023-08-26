// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import "../src/lib/types.sol";
import {CommitmentManager} from "../src/CommitmentManager.sol";
import {CommitmentManagerHandler as Handler} from "./handlers/CommitmentManagerHandler.sol";

contract CommitmentManagerTest is Test {
    CommitmentManager public manager;
    Handler public handler;

    function setUp() public {
        manager = new CommitmentManager(10000);
        handler = new Handler(manager);

        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = Handler.mint.selector;

        targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));

        targetContract(address(handler));
    }

    /*
    function invariant_callSummary() public view {
        handler.callSummary();
    }*/

    /*
    function test_setConstraint(Domain domain, address newAddress, uint256 newSelector) public {
        function (bytes memory) external view constraint;
        assembly {
            constraint.selector := newSelector
            constraint.address := newAddress
        }
        //if (msg.sender != intentManager.owner()) vm.expectRevert();
        intentManager.setConstraint(domain, constraint);
    }*/
}
