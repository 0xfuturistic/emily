// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "uma/core/optimistic-oracle-v3/implementation/OptimisticOracleV3.sol";
import "./BaseConstraintsManager.sol";

import "./lib/types.sol";
import "./lib/Lib.sol";

contract OptimisticConstraintsManager is BaseConstraintsManager, OptimisticOracleV3 {
    using ConstraintsLib for Constraint[];

    uint256 public constant CONSTRAINTS_GAS_LIMIT = 500000;

    constructor(address constraintsAdder) BaseConstraintsManager(constraintsAdder) {}

    function areConstraintsAllSatisfied(bytes memory input, function (bool) external callback, uint256 bond)
        external
        nonReentrant
    {
        _areConstraintsAllSatisfied(input);
    }

    function _areConstraintsAllSatisfied(bytes memory input) internal view override returns (bool satisfied) {
        satisfied = _constraints.areAllSatisfied(input, CONSTRAINTS_GAS_LIMIT);
    }
}
