// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IApp} from "./interfaces/IApp.sol";
import {AppsLib} from "./lib/AppsLib.sol";

struct Apps {
    IApp[] inner;
}

using AppsLib for Apps global;
