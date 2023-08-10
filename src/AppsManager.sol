// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Types.sol";

contract AppsManager {
    Apps apps;

    modifier requireEnoughBalance() {
        _requireEnoughBalance();
        _;
    }

    function _requireEnoughBalance() internal view {
        require(
            address(this).balance >= gasleft() * tx.gasprice,
            "CommitmentAccount: not enough funds"
        );
    }
}
