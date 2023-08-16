// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./types.sol";

library ConstraintsLib {
    function add(Constraint[] storage self, Constraint memory constraint) internal {
        self.push(constraint);
    }

    function satisfied(Constraint[] storage self, bytes memory input, uint256 evaluationGasLimit)
        internal
        view
        returns (bool)
    {
        for (uint256 i = 0; i < self.length; i++) {
            function (bytes memory) external view characteristic = self[i].characteristic;
            (bool success,) = characteristic.address.staticcall{gas: evaluationGasLimit}(
                abi.encodeWithSelector(characteristic.selector, input)
            );
            if (!success) return false;
        }
        return true;
    }

    function count(Constraint[] storage self) internal view returns (uint256) {
        return self.length;
    }
}
