// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {SimpleERC6551Account} from "erc6551/examples/simple/SimpleERC6551Account.sol";
import {ConstraintsManager} from "../ConstraintsManager.sol";

abstract contract BaseAccount is ConstraintsManager, SimpleERC6551Account {
    uint256 constant CONSTRAINTS_GAS_LIMIT = 100;

    function execute_(address to, uint256 value, bytes calldata data, uint256 operation)
        external
        payable
        returns (bytes memory result)
    {
        /// @dev optimistically execute the transaction
        result = this.execute(to, value, data, operation);
        _requireConstraintsSatisfied(to, value, data, operation);
    }

    function _requireConstraintsSatisfied(address to, uint256 value, bytes calldata data, uint256 operation) internal {
        bytes memory domain = "placeholder";
        require(
            _areConstraintsAllSatisfied(
                abi.encode(domain, abi.encode(to, value, data, operation)), CONSTRAINTS_GAS_LIMIT
            )
        );
    }
}
