// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../lib/types.sol";
import "../Screener.sol";

/// @title Commitment PBS (Proposer-Builder-Separation)
contract CommitmentPBS is Screener {
    // TODO: struct for a proper eth2 block. this just a sample.
    /// @dev A struct that represents a beacon block.
    /// @param BlockNumber The block number of the beacon block.
    /// @param Proposer The address of the proposer of the beacon block.
    /// @param Builder The address of the builder of the beacon block.
    /// @param Body The body of the beacon block.
    struct BeaconBlock {
        uint64 BlockNumber;
        address Proposer;
        address Builder;
        bytes Body;
    }

    /// @dev A struct that represents a signed beacon block.
    /// @param block_ The beacon block.
    /// @param signature The signature of the signed beacon block.
    struct SignedBeaconBlock {
        BeaconBlock block_;
        bytes32 signature;
    }

    /// @dev A mapping to keep track of whether a builder has been committed to a specific block number by a proposer.
    ///      The key of the first mapping is the proposer's address, and the key of the second mapping is the block number.
    ///      The value is a boolean indicating whether a builder has been committed to for the first and second keys.
    mapping(address => mapping(uint256 => bool)) public builderIsCommitted;

    /// @dev A mapping to keep track of the specific builder that every proposer has committed to for a specific block number, if any.
    ///      The key of the first mapping is the proposer's address, and the key of the second mapping is the block number.
    ///      The value is the address of the specific builder committed to for the first and second keys.
    mapping(address => mapping(uint256 => address)) public builderCommitted;

    /// @dev Emitted when a new builder is committed to a block number by a proposer.
    /// @param proposer The address of the proposer who made the commitment.
    /// @param builder The address of the builder being committed to.
    /// @param blockNumber The block number for which the builder is being committed to.
    event NewBuilderCommitted(address proposer, address builder, uint64 blockNumber);

    /// @dev Error thrown when a builder is already committed to a block number.
    error BuilderAlreadyCommitted();

    /// @notice This function is used to commit to a builder for a given block number.
    /// @param builder The address of the builder to commit to.
    /// @param blockNumber The block number to commit to the builder for.
    function commitToBuilder(address builder, uint64 blockNumber) external {
        if (builderIsCommitted[msg.sender][blockNumber]) revert BuilderAlreadyCommitted();

        builderIsCommitted[msg.sender][blockNumber] = true;
        builderCommitted[msg.sender][blockNumber] = builder;

        emit NewBuilderCommitted(msg.sender, builder, blockNumber);
    }

    /// @notice This function is used to check whether a SignedBeaconBlock satisfies a commitment
    ///         to a builder the proposer of the block may have made, if any.
    /// @param data The data to be checked for.
    /// @return 1 if the commitment is satisfied, 0 otherwise.
    function commitmentIndicator(bytes memory data) external view returns (uint256) {
        // decode
        (SignedBeaconBlock memory signedBeaconBlock) = abi.decode(data, (SignedBeaconBlock));
        BeaconBlock memory beaconBlock = signedBeaconBlock.block_;
        // get fields from payload
        uint64 blockNumber = beaconBlock.BlockNumber;
        address blockProposer = beaconBlock.Proposer;
        address blockBuilder = beaconBlock.Builder;
        // check if builder is the same as the one committed to by the proposer, if any
        if (
            !builderIsCommitted[blockProposer][blockNumber]
                || blockBuilder == builderCommitted[blockProposer][blockNumber]
        ) {
            return 1;
        } else {
            return 0;
        }
    }
}
