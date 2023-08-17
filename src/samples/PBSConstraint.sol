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

contract PBSConstraint {
    mapping(Proposer => mapping(Height => Builder)) public buildersCommitted;

    error WrongBuilder();

    function commit(Proposer proposer, Height height, Builder builder) external {
        require(msg.sender == Proposer.unwrap(proposer));
        buildersCommitted[proposer][height] = builder;
    }

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
