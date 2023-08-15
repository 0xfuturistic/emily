// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {UserOperation} from "erc4337/core/BaseAccount.sol";
import {UserAccount} from "../../src/UserAccount.sol";

contract Handler {
    UserAccount public account;

    constructor(UserAccount account_) {
        account = account_;
    }

    function validateUserOp(UserOperation calldata userOp) public virtual returns (bool) {
        return account.validateUserOp(userOp);
    }
}
