// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import {console} from "forge-std/console.sol";
import {Intent} from "../../src/lib/types.sol";
import {IntentManager} from "../../src/IntentManager.sol";

contract IntentManagerHandler is CommonBase, StdCheats, StdUtils {
    IntentManager public intentManager;

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

    constructor(IntentManager intentManager_) {
        intentManager = intentManager_;
    }

    function setConstraint(uint256 actorIndexSeed, Intent intent, address newAddress, uint256 newSelector)
        public
        countCall("setConstraint")
        useActor(actorIndexSeed)
    {
        function (bytes memory) external view constraint;
        assembly {
            constraint.selector := newSelector
            constraint.address := newAddress
        }
        if (currentActor != intentManager.owner()) vm.expectRevert();
        intentManager.setConstraint(intent, constraint);
    }

    function callSummary() external view {
        console.log("Call summary:");
        console.log("-------------------");
        console.log("setConstraint", calls["setConstraint"]);
        console.log("-------------------");
    }
}
