// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {SD59x18, sd} from "@prb/math/SD59x18.sol";
import {UD60x18, ud} from "@prb/math/UD60x18.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Screener} from "./Screener.sol";
import "./lib/types.sol";

/// @title CommitmentManager
/// @dev This contract manages commitments as ERC721 tokens. It allows users
//       to mint constraints as commitments and enforces user-defined constraints
///      on token transfers.
contract CommitmentManager is ERC721 {
    uint256 public constant TOTAL_GAS_LIMIT = 50000;

    error OnlyMintingAllowed(address from, address to, uint256 firstTokenId, uint256 batchSize);

    mapping(address => ConstraintSet) internal _userConstraints;

    constructor() ERC721("", "") {}

    modifier Screen(address user, bytes32 region, bytes memory value) {
        if (!screen(user, region, value)) revert UserConstraintsNotSatisfied(user, region, value);
        _;
    }

    function screen(address user, bytes32 region, bytes memory value) public view returns (bool success) {
        /// @dev Validate that userOp satisfies the constraints of the userOp sender
        ConstraintSet storage userConstraints = _getUserConstraintSet(user);
        return userConstraints.isConsistent(
            Assignment({regionRoot: region, value: value}), _getPerConstraintGasLimit(userConstraints.inner.length)
        );
    }

    /// @dev Mint a constraint as a commitment for message sender.
    /// @param constraint The constraint to be minted.
    function mint(Constraint memory constraint) public {
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

    /// @dev Gets the gas limit for every constraint given a number
    ///      of constraints.
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

    /// @dev Hook that is called before any token transfer. Reverts
    //       if the transfer is not a minting operation. Additionally,
    ///      reverts if the transfer does not satisfy the user's
    ///      constraints.
    /// @param from Address sending the tokens.
    /// @param to Address receiving the tokens.
    /// @param firstTokenId ID of the first token being transferred.
    /// @param batchSize Number of tokens being transferred.
    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize)
        internal
        override
        Screen(
            from,
            bytes4(keccak256("_beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize)")),
            abi.encode(from, to, firstTokenId, batchSize)
        )
    {
        if (from != address(0)) {
            revert OnlyMintingAllowed(from, to, firstTokenId, batchSize);
        }
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }
}
