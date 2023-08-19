// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IConstraintsManager {
    /// @dev Adds a new constraint.
    /// @param serializedConstraint Serialized constraint to add
    function add(bytes calldata serializedConstraint) external;
}
