// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./lib/types.sol";
import "./lib/Lib.sol";

/// @title BaseConstraintsManager
/// @dev This is a base contract for managing constraints.
abstract contract BaseConstraintsManager is ReentrancyGuard, AccessControl {
    using ConstraintsLib for Constraint[];

    bytes32 public constant CONSTRAINTS_ADDER_ROLE = keccak256("CONSTRAINTS_ADDER_ROLE");

    Constraint[] internal _constraints;

    error ConstraintsNotAllSatisfied();

    constructor(address constraintsAdder) {
        _grantRole(CONSTRAINTS_ADDER_ROLE, constraintsAdder);
    }

    /*//////////////////////////////////////////////////////////////
                                EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @dev Add a new constraint.
    /// @param contractAddr Address of the contract that contains characteristic function
    /// @param selector Selector of the function be used as characteristic function
    /// @return constraint Constraint that has been added
    function addConstraint(address contractAddr, bytes4 selector)
        external
        virtual
        onlyRole(CONSTRAINTS_ADDER_ROLE)
        returns (Constraint memory constraint)
    {
        constraint = _addConstraint(contractAddr, selector);
    }

    /// @dev Check whether all constraints are satisfied.
    /// @param input Bytes to be checked against the constraints
    /// @return satisfied Boolean value for whether all constraints are satisfied
    function areConstraintsAllSatisfied(bytes memory input) external nonReentrant returns (bool satisfied) {
        satisfied = _areConstraintsAllSatisfied(input);
    }

    /// @dev Get all constraints.
    /// @return constraints_ the array of constraints
    function getConstraints() external view returns (Constraint[] memory constraints_) {
        constraints_ = _getConstraints();
    }

    /// @dev Count the number of constraints.
    /// @return count the number of constraints
    function countConstraints() external view returns (uint256 count) {
        count = _countConstraints();
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @dev Add a new constraint (internal).
    /// @param contractAddr Address of the contract that contains characteristic function
    /// @param selector Selector of the function be used as characteristic function
    /// @return constraint Constraint that has been added
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

    /// @dev Check whether all constraints are satisfied (internal).
    /// @param input Bytes to be checked against the constraints
    /// @return satisfied Boolean value for whether all constraints are satisfied
    function _areConstraintsAllSatisfied(bytes memory input) internal view virtual returns (bool satisfied);

    /// @dev Get all constraints (internal).
    /// @return constraints_ the array of constraints
    function _getConstraints() internal view virtual returns (Constraint[] memory constraints_) {
        constraints_ = _constraints;
    }

    /// @dev Count the number of constraints (internal).
    /// @return count the number of constraints
    function _countConstraints() internal view virtual returns (uint256 count) {
        count = _constraints.count();
    }
}
