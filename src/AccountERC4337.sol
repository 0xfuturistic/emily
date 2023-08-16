// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {BaseAccount as ERC4337BaseAccount, UserOperation} from "erc4337/core/BaseAccount.sol";
import {Account} from "./Account.sol";

abstract contract AccountERC4337 is Account, ERC4337BaseAccount {
    uint256 constant PROVER_GAS_LIMIT = 100;

    function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        override
        returns (uint256 validationData)
    {
        _requireFromEntryPoint();
        validationData = _validateSignature(userOp, userOpHash);
        _validateNonce(userOp.nonce);
        _requireConstraintsSatisfied(userOp);
        _payPrefund(missingAccountFunds);
    }

    function _requireConstraintsSatisfied(UserOperation calldata userOp) internal view {
        uint256 constraintMaxGas = PROVER_GAS_LIMIT / constraints.length;
        require(_satisfiedConstraints(abi.encode(userOp), constraintMaxGas));
    }
}
