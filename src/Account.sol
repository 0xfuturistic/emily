// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./lib/types.sol";
import "./lib/Lib.sol";

contract Account {
    using ConstraintsLib for Constraint[];

    Constraint[] constraints;

    function newConstraint(address contractAddr, bytes4 selector) external returns (Constraint memory constraint) {
        function (bytes memory) external view characteristic = constraint.characteristic;

        assembly {
            characteristic.address := contractAddr
            characteristic.selector := selector
        }

        constraints.add(constraint);
    }

    function getConstraints() external view returns (Constraint[] memory) {
        return constraints;
    }

    function countConstraints() external view returns (uint256 count) {
        count = constraints.count();
    }

    function _satisfiedConstraints(bytes memory input, uint256 evaluationGasLimit) internal view returns (bool) {
        return constraints.satisfied(input, evaluationGasLimit);
    }
}
