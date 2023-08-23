// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {SD59x18, sd} from "@prb/math/SD59x18.sol";
import {UD60x18, ud} from "@prb/math/UD60x18.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Screener} from "./Screener.sol";
import "./lib/types.sol";

/// @title CommitmentManager
/// @dev This contract manages commitments as ERC721 tokens. It allows users
//       to mint commitments as commitments and enforces user-defined commitments
///      on token transfers.
contract CommitmentManager is ERC721 {
    uint256 public constant TOTAL_GAS_LIMIT = 50000;

    error OnlyMintingAllowed(address from, address to, uint256 firstTokenId, uint256 batchSize);

    mapping(address => CommitmentSet) internal _userCommitments;

    constructor() ERC721("", "") {}

    modifier Screen(address user, bytes32 domain, bytes memory value) {
        if (!screen(user, domain, value)) revert UserCommitmentsNotSatisfied(user, domain, value);
        _;
    }

    function screen(address user, bytes32 domain, bytes memory value) public view returns (bool success) {
        /// @dev Validate that userOp satisfies the commitments of the userOp sender
        CommitmentSet storage userCommitments = _getUserCommitmentSet(user);
        return userCommitments.isSatisfied(
            Assignment({domainRoot: domain, value: value}), _getPerCommitmentGasLimit(userCommitments.inner.length)
        );
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

    /// @dev Gets the commitments for a given user.
    /// @param user The user to get commitments for.
    /// @return commitmentSet The commitments for the given user.
    function _getUserCommitmentSet(address user) internal view virtual returns (CommitmentSet storage commitmentSet) {
        commitmentSet = _userCommitments[user];
    }

    /// @dev Gets the gas limit for every commitment given a number
    ///      of commitments.
    /// @param commitmentsCount The number of commitments.
    /// @return commitmentGasLimit The gas limit for every commitments.
    function _getPerCommitmentGasLimit(uint256 commitmentsCount) internal view returns (uint256 commitmentGasLimit) {
        commitmentGasLimit = UD60x18.unwrap(ud(_getTotalGasLimit()).div(ud(commitmentsCount)));
    }

    /// @dev Gets the total gas limit.
    /// @return totalGasLimit The total gas limit.
    function _getTotalGasLimit() internal view virtual returns (uint256 totalGasLimit) {
        totalGasLimit = TOTAL_GAS_LIMIT;
    }

    /// @dev Hook that is called before any token transfer. Reverts
    //       if the transfer is not a minting operation. Additionally,
    ///      reverts if the transfer does not satisfy the user's
    ///      commitments.
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
