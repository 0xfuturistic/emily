// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BaseAccount, UserOperation} from "erc4337/core/BaseAccount.sol";

abstract contract App {
    function run(address semder, bytes calldata data) external pure virtual;
}

abstract contract CommitmentAccount is BaseAccount {
    App[] apps;

    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external virtual override returns (uint256 validationData) {
        /// @dev ensuring there's enough funds to pay for the gas in the worst case so that msg.sender
        ///      doesn't end up holding the bag if there are no funds after the computations.
        if (address(this).balance < gasleft() * tx.gasprice) {
            revert("CommitmentAccount: insufficient funds");
        }

        _requireFromEntryPoint();
        validationData = _validateSignature(userOp, userOpHash);
        _validateNonce(userOp.nonce);

        for (uint i = 0; i < apps.length; i++) {
            apps[i].run(
                userOp.sender,
                abi.encode(
                    apps,
                    abi.encode(
                        userOp,
                        userOpHash,
                        missingAccountFunds,
                        validationData
                    )
                )
            );
        }

        _payPrefund(missingAccountFunds);
    }
}
