// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import "../src/lib/types.sol";
import {CommitmentManager} from "../src/CommitmentManager.sol";
import {Screener} from "../src/Screener.sol";

contract ScreenTest is Test {
    using CommitmentsLib for Commitment[];

    Screener public screen;

    function setUp() public {
        screen = new Screener();
    }
}
