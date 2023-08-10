// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BaseAccount, UserOperation} from "erc4337/core/BaseAccount.sol";

type App is address;

library AppLib {
    function run(App app, bytes memory data) internal view {
        (bool success, ) = App.unwrap(app).staticcall(
            abi.encodeWithSignature("run(bytes calldata)", data)
        );

        if (!success) {
            revert("AppLib: app execution failed");
        }
    }
}

using AppLib for App;

abstract contract AppsAccount is BaseAccount {
    App[] public apps;

    function newApp(App app) internal {
        _requireFromEntryPoint();
        apps.push(app);
    }

    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external virtual override returns (uint256 validationData) {
        _requireFromEntryPoint();
        /// @dev ensuring there's enough funds to pay for the gas in the worst case so that msg.sender
        ///      doesn't end up holding the bag if there are no funds after the computations.
        _requireEnoughBalance(); // new
        validationData = _validateSignature(userOp, userOpHash);
        _validateNonce(userOp.nonce);
        _runApps( // new
            abi.encode(userOp, userOpHash, missingAccountFunds, validationData)
        );
        _payPrefund(missingAccountFunds);
    }

    function _requireEnoughBalance() internal view {
        require(
            address(this).balance >= gasleft() * tx.gasprice,
            "CommitmentAccount: not enough funds"
        );
    }

    function _runApps(bytes memory data) internal view {
        for (uint i = 0; i < apps.length; i++) {
            apps[i].run(data);
        }
    }
}
