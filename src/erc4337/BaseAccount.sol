// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {BaseAccount as ERC4337BaseAccount, UserOperation} from "erc4337/core/BaseAccount.sol";
import {ConstraintsManager} from "../ConstraintsManager.sol";
import "../lib/types.sol";

abstract contract BaseAccount is ConstraintsManager, ERC4337BaseAccount {
    uint256 public constant CONSTRAINTS_GAS_LIMIT = 1 ether;

    constructor(address constraintsAdder) ConstraintsManager(constraintsAdder) {}

    function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        override
        returns (uint256 validationData)
    {
        _requireFromEntryPoint();
        validationData = _validateSignature(userOp, userOpHash);
        _validateNonce(userOp.nonce);
        /// @dev new line
        _requireConstraintsAreSatisfied(abi.encode(userOp), CONSTRAINTS_GAS_LIMIT);
        _payPrefund(missingAccountFunds);
    }
}
