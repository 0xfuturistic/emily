// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../lib/types.sol";
import "../Screener.sol";

/// @title PEPC
/// @dev This contract implements a sample eth2 block and a PBS commitment
///      relation for the builder committed by the proposer.
contract PEPC is Screener {
    type Height is uint256;
    type Proposer is address;
    type Builder is address;

    // TODO: struct for a proper eth2 block. this just a sample.
    struct Block {
        Height height;
        Proposer proposer;
        Builder builder;
        bytes body;
    }

    struct SignedBlock {
        Block block_;
        bytes32 signature;
    }

    /// @dev Constructor for the PEPC contract.
    constructor(address commitmentManagerAddress) Screener(commitmentManagerAddress) {}

    /// @dev Mapping of builders committed by proposers at a certain height.
    mapping(Proposer => mapping(Height => Builder)) public buildersCommitted;

    /// @dev Error message when the builder committed by the proposer is not
    ///      the same as the one in the block.
    error WrongBuilder();

    /// @dev Function to check if a block satisfies the proposer's commitments.
    /// @param signedBlock The signed block.
    function on_block(SignedBlock memory signedBlock)
        external
        Screen(Proposer.unwrap(signedBlock.block_.proposer), keccak256(abi.encode(this.on_block)), abi.encode(signedBlock))
    {}

    /// @dev Function for msg.sender to commit to a builder for a certain height.
    /// @param height The height of the block.
    /// @param builder The address of the builder to commit to.
    function commitBuilder(Height height, Builder builder) external {
        (bool success,) = address(commitmentManager).delegatecall(
            abi.encodeWithSelector(
                commitmentManager.mint.selector,
                Commitment({domainRoot: keccak256(abi.encode(this.on_block)), relation: this.PBSCommitmentRelation})
            )
        );
        require(success);

        buildersCommitted[Proposer.wrap(msg.sender)][height] = builder;
    }

    /// @dev Function to validate that the PBS commitment relation is satisfied.
    ///      Reverts if the commitment is not satisfied.
    /// @param input The input data containing the signed block.
    function PBSCommitmentRelation(bytes memory input) external view {
        SignedBlock memory signedBlock = abi.decode(input, (SignedBlock));
        Builder builder = signedBlock.block_.builder;
        Builder committedBuilder = buildersCommitted[signedBlock.block_.proposer][signedBlock.block_.height];

        if (Builder.unwrap(builder) != Builder.unwrap(committedBuilder)) revert WrongBuilder();
    }
}
