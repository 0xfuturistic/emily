// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./lib/types.sol";
import "./lib/Lib.sol";

abstract contract BaseConstraintsManager is ReentrancyGuard, AccessControl {
    using ConstraintsLib for Constraint[];

    bytes32 public constant CONSTRAINTS_ADDER_ROLE = keccak256("CONSTRAINTS_ADDER_ROLE");

    Constraint[] internal _constraints;

    error ConstraintsNotAllSatisfied();

    /*//////////////////////////////////////////////////////////////
                                EXTERNAL
    //////////////////////////////////////////////////////////////*/

    function addConstraint(address contractAddr, bytes4 selector)
        external
        virtual
        onlyRole(CONSTRAINTS_ADDER_ROLE)
        returns (Constraint memory constraint)
    {
        constraint = _addConstraint(contractAddr, selector);
    }

    function areConstraintsAllSatisfied(bytes memory input) external nonReentrant returns (bool satisfied) {
        satisfied = _areConstraintsAllSatisfied(input);
    }

    function getConstraints() external view returns (Constraint[] memory constraints_) {
        constraints_ = _getConstraints();
    }

    function countConstraints() external view returns (uint256 count) {
        count = _countConstraints();
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    function _addConstraint(address contractAddr, bytes4 selector)
        internal
        virtual
        returns (Constraint memory constraint)
    {
        /// @dev constraint.characteristic is the characteristic function of the constraint
        function (bytes memory) external view characteristic = constraint.characteristic;

        assembly {
            /// @dev Set the characteristic function address and selector.
            characteristic.address := contractAddr
            characteristic.selector := selector
        }

        _constraints.add(constraint);
    }

    function _areConstraintsAllSatisfied(bytes memory input) internal view virtual returns (bool satisfied);

    function _getConstraints() internal view virtual returns (Constraint[] memory constraints_) {
        constraints_ = _constraints;
    }

    function _countConstraints() internal view virtual returns (uint256 count) {
        count = _constraints.count();
    }
}
