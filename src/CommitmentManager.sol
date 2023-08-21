// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {SD59x18, sd} from "@prb/math/SD59x18.sol";
import {UD60x18, ud} from "@prb/math/UD60x18.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./lib/types.sol";

contract CommitmentManager is ERC721 {
    uint256 public constant TOTAL_GAS_LIMIT = 50000;

    mapping(address => ConstraintSet) internal _userConstraints;

    constructor() ERC721("", "") {}

    modifier Screen(address user, bytes32 region, bytes memory value) {
        require(screen(user, region, value), "Aggregator: user constraints not satisfied");
        _;
    }

    function screen(address user, bytes32 region, bytes memory value) public view returns (bool success) {
        /// @dev Validate that userOp satisfies the constraints of the userOp sender
        ConstraintSet storage userConstraints = _getUserConstraintSet(user);
        return userConstraints.isConsistent(
            Assignment({regionRoot: keccak256(abi.encodePacked(region)), value: value}),
            _getPerConstraintGasLimit(userConstraints.inner.length)
        );
    }

    function mint(Constraint memory constraint) public Screen(msg.sender, this.mint.selector, abi.encode(constraint)) {
        uint256 constraintId = uint256(keccak256(abi.encode(msg.sender, constraint)));
        _mint(msg.sender, constraintId);
        _userConstraints[msg.sender].add(constraint);
    }

    /// @dev Gets the constraints for a given user.
    /// @param user The user to get constraints for.
    /// @return constraintSet The constraints for the given user.
    function _getUserConstraintSet(address user) internal view virtual returns (ConstraintSet storage constraintSet) {
        constraintSet = _userConstraints[user];
    }

    /// @dev Gets the gas limit for every constraint given a number of constraints.
    /// @param constraintsCount The number of constraints.
    /// @return constraintGasLimit The gas limit for every constraints.
    function _getPerConstraintGasLimit(uint256 constraintsCount) internal view returns (uint256 constraintGasLimit) {
        constraintGasLimit = UD60x18.unwrap(ud(_getTotalGasLimit()).div(ud(constraintsCount)));
    }

    /// @dev Gets the total gas limit.
    /// @return totalGasLimit The total gas limit.
    function _getTotalGasLimit() internal view virtual returns (uint256 totalGasLimit) {
        totalGasLimit = TOTAL_GAS_LIMIT;
    }
}
