// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {CommitmentsAccount} from "../src/CommitmentsAccount.sol";

contract CommitmentsAccountTest is Test {
    CommitmentsAccount public account;

    function setUp() public {
        account = new CommitmentsAccount();
    }

    function test_newCommitment(address newAddress, bytes4 newSelector)
        public
        returns (function(bytes memory) external view fun)
    {
        assembly {
            fun.selector := newSelector
            fun.address := newAddress
        }

        account.newCommitment(fun);
        assertEq(abi.encode(account.commitments(account.commitmentsCount() - 1)), abi.encode(fun));
    }

    function test_validateCommitments(bytes memory data) public returns (bool success) {
        for (uint256 i = 0; i < account.commitmentsCount(); i++) {
            (success,) =
                account.commitments(i).address.staticcall(abi.encodeWithSelector(account.commitments(i).selector, data));
            if (!success) break;
        }

        assertEq(account.validateCommitments(data), success);
    }
}
