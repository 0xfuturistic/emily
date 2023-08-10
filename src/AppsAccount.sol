// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BaseAccount, UserOperation} from "erc4337/core/BaseAccount.sol";
import {AppsManager} from "./AppsManager.sol";

abstract contract AppsAccount is AppsManager, BaseAccount {
    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external virtual override returns (uint256 validationData) {
        _requireFromEntryPoint();
        /// @dev NEW: ensures there's enough funds to pay for the gas in the worst case so that msg.sender
        ///      doesn't end up holding the bag if there are no funds after the computations.
        _requireEnoughBalance(); // new
        validationData = _validateSignature(userOp, userOpHash);
        _validateNonce(userOp.nonce);
        /// @dev NEW
        apps.run(
            abi.encode(userOp, userOpHash, missingAccountFunds, validationData)
        );
        _payPrefund(missingAccountFunds);
    }
}
