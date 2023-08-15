// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2, console} from "forge-std/Test.sol";

import {UserOperation} from "erc4337/core/BaseAccount.sol";
import {UserAccount} from "../src/UserAccount.sol";

import {Handler} from "./handlers/Handler.sol";

contract UserAccountTest is Test {
    UserAccount account;
    Handler public handler;

    function setUp() public {
        account = new UserAccount();

        handler = new Handler(account);

        targetContract(address(handler));
    }

    function test_initialize(uint256 PROVING_MAX_GAS) public {
        account.initialize(PROVING_MAX_GAS);
    }

    function test_newConstraint(address contractAddr, bytes4 selector) public {
        account.newConstraint(contractAddr, selector);
    }

    function validateUserOp(UserOperation calldata userOp) public returns (bool) {
        handler.validateUserOp(userOp);
    }
}
