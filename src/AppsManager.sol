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

contract AppsManager {
    using AppLib for App;
    App[] public apps;

    function _runApps(bytes memory data) internal view {
        for (uint i = 0; i < apps.length; i++) {
            _runApp(apps[i], data);
        }
    }

    function _runApp(App app, bytes memory data) internal view {
        app.run(data);
    }

    function _newApps(App[] calldata app) internal {
        for (uint i = 0; i < app.length; i++) {
            _newApp(app[i]);
        }
    }

    function _newApp(App app) internal {
        apps.push(app);
    }

    function _requireEnoughBalance() internal view {
        require(
            address(this).balance >= gasleft() * tx.gasprice,
            "CommitmentAccount: not enough funds"
        );
    }
}
