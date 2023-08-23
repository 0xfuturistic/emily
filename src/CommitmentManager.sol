// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {SoulboundERC721} from "./SoulboundERC721.sol";
import "./lib/types.sol";

/// @title CommitmentManager
/// @dev This contract manages commitments as soul-bound ERC721 tokens. It allows users
//       to mint commitments as commitments and enforces user-defined commitments
///      on token transfers.
contract CommitmentManager is SoulboundERC721 {
    uint256 public immutable USER_COMMITMENTS_GAS_LIMIT;

    mapping(address => CommitmentSet) internal _userCommitments;

    constructor(uint256 userCommitmentsGasLimit) SoulboundERC721("", "") {
        USER_COMMITMENTS_GAS_LIMIT = userCommitmentsGasLimit;
    }

    /// @dev Mint a commitment for msg.sender.
    /// @param commitment The commitment to add to the user's commitments.
    function mint(Commitment memory commitment) external {
        uint256 commitmentId = uint256(keccak256(abi.encode(msg.sender, commitment)));
        _mint(msg.sender, commitmentId);
        /// @dev Wrap the commitment in a CommitmentSet and add it to the user's commitments.
        CommitmentSet memory commitmentSet = CommitmentSetLib.wrap(commitment);
        _userCommitments[msg.sender].add(commitmentSet);
    }

    /// @dev Checks if the commitments of a user are satisfied for a given domain and value.
    /// @param user The address of the user whose commitments are being checked.
    /// @param domain The domain of the commitment being checked.
    /// @param value The value of the commitment being checked.
    /// @return True if and only if the user's commitments are satisfied.
    function areUserCommitmentsSatisfied(address user, bytes32 domain, bytes memory value)
        external
        view
        returns (bool)
    {
        CommitmentSet storage userCommitments = _getUserCommitmentSet(user);
        return userCommitments.isSatisfied(Assignment({domainRoot: domain, value: value}), USER_COMMITMENTS_GAS_LIMIT);
    }

    /// @dev Gets the commitments for a given user.
    /// @param user The user to get commitments for.
    /// @return commitmentSet The commitments for the given user.
    function _getUserCommitmentSet(address user) internal view virtual returns (CommitmentSet storage commitmentSet) {
        commitmentSet = _userCommitments[user];
    }
}
