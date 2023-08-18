// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./BaseConstraintsManager.sol";
import "./lib/types.sol";
import "./lib/Lib.sol";

/// @title PessimisticConstraintsManager
/// @dev A contract that manages constraints for pessimistic strategies.
contract PessimisticConstraintsManager is BaseConstraintsManager {
    using ConstraintsLib for Constraint[];

    constructor(address constraintsAdder) BaseConstraintsManager(constraintsAdder) {}

    uint256 public constant CONSTRAINTS_GAS_LIMIT = 500000;

    /// @dev Checks if all constraints are satisfied for the given input.
    /// @param input The input to check constraints against.
    /// @return satisfied True if all constraints are satisfied, false otherwise.
    function _areConstraintsAllSatisfied(bytes memory input) internal view override returns (bool satisfied) {
        satisfied = _constraints.areAllSatisfied(input, CONSTRAINTS_GAS_LIMIT);
    }
}
