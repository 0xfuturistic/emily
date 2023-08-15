// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./types.sol";

library ConstraintsLib {
    function add(Constraint[] storage constraints, Constraint memory constraint) internal {
        constraints.push(constraint);
    }

    function satisfied(Constraint[] storage constraints, bytes memory input, uint256 evaluationGasLimit)
        internal
        view
        returns (bool)
    {
        for (uint256 i = 0; i < constraints.length; i++) {
            function (bytes memory) external view characteristic = constraints[i].characteristic;
            (bool success,) = characteristic.address.staticcall{gas: evaluationGasLimit}(
                abi.encodeWithSelector(characteristic.selector, input)
            );
            if (!success) return false;
        }
        return true;
    }

    function count(Constraint[] storage constraints) internal view returns (uint256) {
        return constraints.length;
    }
}
