// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Types.sol";

contract AppsManager {
    Apps apps;

    modifier runApps(bytes memory data) {
        _requireEnoughBalance();
        _;
        apps.run(data);
    }

    /// @dev NEW: ensures there's enough funds to pay for the gas in the worst case so that msg.sender
    ///      doesn't end up holding the bag if there are no funds after the computations.
    function _requireEnoughBalance() internal view {
        require(
            address(this).balance >= gasleft() * tx.gasprice,
            "CommitmentAccount: not enough funds"
        );
    }
}
