// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {BaseAccount as ERC4337BaseAccount, UserOperation} from "erc4337/core/BaseAccount.sol";
import {BaseConstraintsManager} from "../BaseConstraintsManager.sol";
import "../lib/types.sol";

abstract contract BaseAccount is BaseConstraintsManager, ERC4337BaseAccount {
    constructor(address constraintsAdder) BaseConstraintsManager(constraintsAdder) {}

    function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        override
        returns (uint256 validationData)
    {
        _requireFromEntryPoint();
        validationData = _validateSignature(userOp, userOpHash);
        _validateNonce(userOp.nonce);
        /// @dev new line
        //_requireConstraintsAreSatisfied(abi.encode(userOp), CONSTRAINTS_GAS_LIMIT);
        _payPrefund(missingAccountFunds);
    }
}
