// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2, console} from "forge-std/Test.sol";
import {UserOperation} from "erc4337/core/BaseAccount.sol";
import {SimpleAccount} from "../../../src/erc4337/SimpleAccount.sol";

contract SimpleAccountHandler is Test {
    SimpleAccount public account;
    address public constraintsAdder;

    constructor(SimpleAccount account_, address constraintsAdder_) {
        account = account_;
        constraintsAdder = constraintsAdder_;
    }

    function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        virtual
        returns (uint256 validationData)
    {
        uint256 gasBefore = gasleft();
        validationData = account.validateUserOp(userOp, userOpHash, missingAccountFunds);
        uint256 gasAfter = gasleft();

        /*if (account.countConstraints() > 0) {
            require(
                account.CONSTRAINTS_GAS_LIMIT() >= gasBefore - gasAfter,
                "AccountHandler: validateUserOp gas usage too high"
            );
        }*/
    }

    function addConstraint(address contractAddr, bytes4 selector) external virtual {
        vm.prank(constraintsAdder);
        account.addConstraint(contractAddr, selector);
    }
}
