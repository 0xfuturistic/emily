// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

type Height is uint256;

type Proposer is address;

type Builder is address;

struct Block {
    Height height;
    Proposer proposer;
    Builder builder;
    bytes32 bodyRoot;
}

struct SignedBlock {
    Block block_;
    bytes32 signature;
}

/// @title PBSConstraint
/// @dev This contract implements a constraint on the commitment of builders by proposers.
/// Builders are committed to building blocks at specific heights by proposers.
/// The contract verifies that the builder committed by the proposer is the same as the one in the block.
contract PBSConstraint {
    /// @dev Maps a proposer to a mapping of heights to builders.
    /// buildersCommitted[propser][height] = builder
    mapping(Proposer => mapping(Height => Builder)) public buildersCommitted;

    /// @dev Error message when the builder committed by the proposer is not the same as the one in the block.
    error WrongBuilder();

    /// @dev Allows a proposer to commit a builder to a specific height.
    /// @param proposer The proposer committing the builder.
    /// @param height The height the builder is committed to.
    /// @param builder The builder being committed.
    function commit(Proposer proposer, Height height, Builder builder) external {
        require(msg.sender == Proposer.unwrap(proposer));
        buildersCommitted[proposer][height] = builder;
    }

    /// @dev Validates the commitment of a builder by a proposer.
    /// @param input The signed block containing the builder's commitment.
    function validateBuilderCommitment(bytes memory input) external view {
        SignedBlock memory signedBlock = abi.decode(input, (SignedBlock));
        Block memory block_ = signedBlock.block_;

        Builder builderBlock = block_.builder;
        Builder builderCommitted = buildersCommitted[block_.proposer][block_.height];

        /// @dev check if a builder has been commmitted and if it is the same as the one in the block
        if (
            Builder.unwrap(builderCommitted) != address(0)
                && Builder.unwrap(builderBlock) != Builder.unwrap(builderCommitted)
        ) {
            revert WrongBuilder();
        }
    }
}
