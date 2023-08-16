// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./lib/types.sol";
import "./lib/Lib.sol";

contract ConstraintsManager is ReentrancyGuard, AccessControl {
    using ConstraintsLib for Constraint[];

    bytes32 public constant CONSTRAINTS_ADDER_ROLE = keccak256("CONSTRAINTS_ADDER_ROLE");

    Constraint[] internal _constraints;

    error ConstraintsNotSatisfied();

    constructor(address constraintsAdder) {
        _grantRole(CONSTRAINTS_ADDER_ROLE, constraintsAdder);
    }

    function addConstraint(address contractAddr, bytes4 selector)
        external
        virtual
        onlyRole(CONSTRAINTS_ADDER_ROLE)
        returns (Constraint memory constraint)
    {
        constraint = _addConstraint(contractAddr, selector);
    }

    function areConstraintsAllSatisfied(bytes memory input, uint256 absoluteGasLimit)
        external
        nonReentrant
        returns (bool satisfied)
    {
        satisfied = _areConstraintsAllSatisfied(input, absoluteGasLimit);
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
            characteristic.address := contractAddr
            characteristic.selector := selector
        }

        _constraints.add(constraint);
    }

    function _areConstraintsAllSatisfied(bytes memory input, uint256 absoluteGasLimit)
        internal
        virtual
        returns (
            //nonReentrant
            bool satisfied
        )
    {
        satisfied = _constraints.areAllSatisfied(input, absoluteGasLimit);
    }

    function _requireConstraintsAreSatisfied(bytes memory input, uint256 absoluteGasLimit) internal virtual {
        if (!_areConstraintsAllSatisfied(input, absoluteGasLimit)) {
            revert ConstraintsNotSatisfied();
        }
    }

    function _getConstraints() internal view virtual returns (Constraint[] memory constraints_) {
        constraints_ = _constraints;
    }

    function _countConstraints() internal view virtual returns (uint256 count) {
        count = _constraints.count();
    }
}
