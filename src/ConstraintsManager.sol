// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./lib/types.sol";
import "./lib/Lib.sol";

abstract contract ConstraintsManager is ReentrancyGuard {
    using ConstraintsLib for Constraint[];

    Constraint[] _constraints;

    function getConstraints() external view returns (Constraint[] memory constraints_) {
        constraints_ = _getConstraints();
    }

    function countConstraints() external view returns (uint256 count) {
        count = _countConstraints();
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    function _addConstraint(address contractAddr, bytes4 selector) internal returns (Constraint memory constraint) {
        /// @dev constraint.characteristic is the characteristic function of the constraint
        function (bytes memory) external view characteristic = constraint.characteristic;

        assembly {
            characteristic.address := contractAddr
            characteristic.selector := selector
        }

        _constraints.add(constraint);
    }

    function _areConstraintsAllSatisfied(bytes memory input, uint256 absoluteGasLimit)
        internal
        nonReentrant
        returns (bool satisfied)
    {
        satisfied = _constraints.areAllSatisfied(input, absoluteGasLimit);
    }

    function _getConstraints() internal view returns (Constraint[] memory constraints_) {
        constraints_ = _constraints;
    }

    function _countConstraints() internal view returns (uint256 count) {
        count = _constraints.count();
    }
}
