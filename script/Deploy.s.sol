// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/CommitmentManager.sol";

contract CommitmentManagerScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        CommitmentManager commitmentManager = new CommitmentManager(1 ether);
        vm.stopBroadcast();
    }
}
