// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Aggregator} from "../src/Aggregator.sol";

contract AggregatorTest is Test {
    Aggregator public aggregator;

    function setUp() public {
        aggregator = new Aggregator();
    }
}
