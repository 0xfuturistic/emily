// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {BaseAccount as ERC4337BaseAccount, UserOperation} from "erc4337/core/BaseAccount.sol";
import "solhooks/Hooks.sol";
import "../IntentManager.sol";

abstract contract BaseAccount is ERC4337BaseAccount, IntentManager, Hooks {
    constructor(address initialOwner) IntentManager(initialOwner) {}

    function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        override
        preHook(
            this.assertValidity,
            abi.encode(
                abi.encodeWithSelector(this.validateUserOp.selector), abi.encode(userOp, userOpHash, missingAccountFunds)
            ),
            MAX_GAS_LIMIT
        )
        returns (uint256 validationData)
    {
        validationData = this.validateUserOp(userOp, userOpHash, missingAccountFunds);
    }
}
