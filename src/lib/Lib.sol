// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./types.sol";

/// @title ConstraintsLib
/// @dev Library for managing constraints.
library ConstraintsLib {
    /// @dev Adds a constraint.
    /// @param self The constraints array.
    /// @param constraint The constraint to add.
    function add(Constraint[] storage self, Constraint memory constraint) internal {
        self.push(constraint);
    }

    /// @dev Checks if all constraints are satisfied.
    /// @param self The constraints array.
    /// @param input The input to evaluate the constraints against.
    /// @param absoluteGasLimit The total gas limit to use for evaluating constraints.
    /// @return bool that is true if and only if all constraints are satisfied.
    function areAllSatisfied(Constraint[] storage self, bytes memory input, uint256 absoluteGasLimit)
        internal
        view
        returns (bool)
    {
        if (self.length == 0) return true;
        uint256 characteristicGasLimit = absoluteGasLimit / self.length; // todo: use math library for division
        for (uint256 i = 0; i < self.length; i++) {
            function (bytes memory) external view characteristic = self[i].characteristic;
            (bool success,) = characteristic.address.staticcall{gas: characteristicGasLimit}(
                abi.encodeWithSelector(characteristic.selector, input)
            );
            if (!success) return false;
        }
        return true;
    }

    /// @dev Returns the number of constraints.
    /// @param self The constraints array.
    /// @return count_ The number of constraints.
    function count(Constraint[] storage self) internal view returns (uint256 count_) {
        count_ = self.length;
    }
}
