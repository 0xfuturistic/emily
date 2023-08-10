// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BaseAccount, UserOperation} from "erc4337/core/BaseAccount.sol";
import {AppsManager} from "./AppsManager.sol";

abstract contract AppsAccount is AppsManager, BaseAccount {
    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    )
        external
        virtual
        override
        runApps(
            abi.encode(userOp, userOpHash, missingAccountFunds, validationData)
        )
        returns (uint256 validationData)
    {
        _requireFromEntryPoint();
        validationData = _validateSignature(userOp, userOpHash);
        _validateNonce(userOp.nonce);
        _payPrefund(missingAccountFunds);
    }
}
