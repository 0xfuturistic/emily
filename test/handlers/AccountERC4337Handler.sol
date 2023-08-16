// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {UserOperation} from "erc4337/core/BaseAccount.sol";
import {AccountERC4337} from "../../src/AccountERC4337.sol";

contract AccountERC4337Handler {
    AccountERC4337 public account;

    constructor(AccountERC4337 account_) {
        account = account_;
    }

    function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        virtual
        returns (uint256 validationData)
    {
        return account.validateUserOp(userOp, userOpHash, missingAccountFunds);
    }
}
