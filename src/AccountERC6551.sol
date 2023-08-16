// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {UserOperation} from "erc4337/core/BaseAccount.sol";
import {SimpleERC6551Account} from "erc6551/examples/simple/SimpleERC6551Account.sol";
import {Account as BaseAccount} from "./Account.sol";

abstract contract AccountERC6551 is BaseAccount, SimpleERC6551Account {
    uint256 constant PROVER_GAS_LIMIT = 100;

    function execute_(address to, uint256 value, bytes calldata data, uint256 operation)
        external
        payable
        returns (bytes memory result)
    {
        this.execute(to, value, data, operation);
    }

    function _requireConstraintsSatisfied(UserOperation calldata userOp) internal view {
        uint256 constraintMaxGas = PROVER_GAS_LIMIT / constraints.length;
        require(_satisfiedConstraints(abi.encode(userOp), constraintMaxGas));
    }
}
