// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {SoulboundERC721} from "./SoulboundERC721.sol";
import "./lib/types.sol";

/// @title CommitmentManager
/// @dev This contract manages commitments as soul-bound ERC721 tokens. It allows
//       users to mint commitments and enforces provides a method to check if a
///      user's commitments are satisfied.
contract CommitmentManager is SoulboundERC721 {
    uint256 public immutable USER_COMMITMENTS_GAS_LIMIT;

    mapping(address => Commitment) internal _userCommitment;

    constructor(uint256 userCommitmentsGasLimit) SoulboundERC721("UserCommitments", "CMT") {
        USER_COMMITMENTS_GAS_LIMIT = userCommitmentsGasLimit;
    }

    /// @dev Mint a commitment for msg.sender.
    /// @param commitment The commitment to add to the user's commitments.
    function mint(Commitment memory commitment) external {
        uint256 commitmentId = uint256(keccak256(abi.encode(msg.sender, commitment)));
        _mint(msg.sender, commitmentId);
        // Wrap commitment in a CommitmentSet and add it to the user's commitments.
        _userCommitment[msg.sender].add(commitment);
    }

    /// @dev Checks if a user's commitments are satisfied for a domain and value.
    /// @param user The address of the user whose commitments are being checked.
    /// @param target The domain of the commitment being checked.
    /// @param value The value of the commitment being checked.
    /// @return True if and only if the user's commitments are satisfied.
    function areUserCommitmentsSatisfied(address user, bytes32 target, bytes memory value)
        external
        view
        returns (bool)
    {
        Commitment memory userCommitment = _getUserCommitmentSet(user);
        Assignment memory assignment = Assignment({target: target, value: value});
        return userCommitment.isSolution(assignment, USER_COMMITMENTS_GAS_LIMIT);
    }

    /// @dev Gets the commitments for a given user.
    /// @param user The user to get commitments for.
    /// @return commitment The commitments for the given user.
    function _getUserCommitmentSet(address user) internal view virtual returns (Commitment storage commitment) {
        commitment = _userCommitment[user];
    }
}
