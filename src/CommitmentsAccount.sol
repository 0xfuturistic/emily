// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {UserOperation, UserOperationLib} from "erc4337/interfaces/UserOperation.sol";
import {Burn} from "optimism-contracts/libraries/Burn.sol";

using UserOperationLib for UserOperation;

contract CommitmentsAccount {
    function (bytes memory) external view[] public commitments;

    modifier meter() {
        uint256 initialGas = gasleft();
        _;
        Burn.gas(initialGas - gasleft());
    }

    function validateUserOp(UserOperation calldata userOp) public view meter returns (bool) {
        if (address(this).balance >= gasleft() * tx.gasprice) return false;
        return validateCommitments(abi.encode(userOp));
    }

    function validateCommitments(bytes memory data) public view returns (bool success) {
        for (uint256 i = 0; i < commitments.length; i++) {
            (success,) = commitments[i].address.staticcall(abi.encodeWithSelector(commitments[i].selector, data));
            if (!success) return false;
        }
    }

    function newCommitment(function (bytes memory) external view commitment) public {
        commitments.push(commitment);
    }

    function commitmentsCount() public view returns (uint256) {
        return commitments.length;
    }
}
