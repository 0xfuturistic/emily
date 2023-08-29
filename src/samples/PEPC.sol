// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../lib/types.sol";
import "../Screener.sol";

/// @title PEPC
/// @dev This contract implements a sample eth2 block and a PBS commitment
///      for the builder committed by the proposer.
contract PEPC is Screener {
    type Height is uint256;
    type Proposer is address;
    type Builder is address;

    // TODO: struct for a proper eth2 block. this just a sample.
    struct BeaconBlock {
        Height height;
        Proposer proposer;
        Builder builder;
        bytes body;
    }

    struct SignedBeaconBlock {
        BeaconBlock block_;
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
    /// @param signedBeaconBlock The signed block.
    function on_block(SignedBeaconBlock memory signedBeaconBlock)
        external
        Screen(
            Proposer.unwrap(signedBeaconBlock.block_.proposer),
            keccak256(abi.encode(this.on_block)),
            abi.encode(signedBeaconBlock)
        )
    {}

    /// @dev Function for msg.sender to commit to a builder for a certain height.
    /// @param height The height of the block.
    /// @param builder The address of the builder to commit to.
    function commitBuilder(Height height, Builder builder) external {
        //commitmentManager.mint(keccak256(abi.encode(this.on_block, height)), this.PBSCommitmentRelation);
        buildersCommitted[Proposer.wrap(msg.sender)][height] = builder;
    }

    /// @dev Function to validate that the PBS commitment relation is satisfied.
    ///      Reverts if the commitment is not satisfied.
    /// @param value The input data containing the signed block.
    function PBSCommitmentRelation(bytes memory value) external view returns (bool) {
        SignedBeaconBlock memory signedBeaconBlock = abi.decode(value, (SignedBeaconBlock)); // todo: an assignment is received here
        Builder builder = signedBeaconBlock.block_.builder;
        Builder committedBuilder = buildersCommitted[signedBeaconBlock.block_.proposer][signedBeaconBlock.block_.height];

        if (Builder.unwrap(builder) != Builder.unwrap(committedBuilder)) return false;
        return true;
    }
}
