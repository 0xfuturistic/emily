// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {BaseAccount as ERC4337BaseAccount, UserOperation} from "erc4337/core/BaseAccount.sol";
import {BaseConstraintsManager} from "../BaseConstraintsManager.sol";
import "../lib/types.sol";

abstract contract BaseAccount is BaseConstraintsManager, ERC4337BaseAccount {
    constructor(address constraintsAdder) BaseConstraintsManager(constraintsAdder) {}

    /**
     * @dev Validates a user operation and returns validation data.
     * @param userOp The user operation to validate.
     * @param userOpHash The hash of the user operation.
     * @param missingAccountFunds The amount of missing account funds.
     * @return validationData The validation data.
     */
    function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        override
        returns (uint256 validationData)
    {
        _requireFromEntryPoint();
        validationData = _validateSignature(userOp, userOpHash);
        _validateNonce(userOp.nonce);
        //_requireConstraintsAreSatisfied(abi.encode(userOp), CONSTRAINTS_GAS_LIMIT);
        _payPrefund(missingAccountFunds);
    }
}
