// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IApp} from "../interfaces/IApp.sol";
import "../Types.sol";

library AppsLib {
    function run(Apps storage apps, bytes memory data) internal view {
        for (uint i = 0; i < apps.inner.length; i++) {
            apps.inner[i].run(data);
        }
    }

    function commit(Apps storage apps, IApp app) internal {
        apps.inner.push(app);
    }
}
