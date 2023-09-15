// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../lib/types.sol";
import "../Screener.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Commitment PBS (Proposer-Builder-Separation)
contract CommitmentPBS is Screener, Ownable {
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

    /// @dev A mapping to keep track of whether an account has committed to builder for a block number.
    ///      The key of the first mapping is the account's address, and the key of the second mapping is the block number.
    ///      The value is a boolean indicating whether a builder has been committed to.
    mapping(address => mapping(uint256 => bool)) public builderIsCommitted;

    /// @dev A mapping to keep track of the builder an account has committed to for a block number.
    ///      The key of the first mapping is the account's address, and the key of the second mapping is the block number.
    ///      The value is the address of the builder committed to.
    mapping(address => mapping(uint256 => address)) public builderCommitted;

    /// @dev Emitted when a new builder is committed for a block number.
    /// @param account The address of the account making the commitment.
    /// @param builder The address of the builder being committed to.
    /// @param blockNumber The block number for which the builder is being committed to.
    event NewBuilderCommitted(address account, address builder, uint64 blockNumber);

    /// @dev Error thrown when a builder is already committed for a block number.
    error BuilderAlreadyCommitted();

    /// @notice This function is used to commit to a builder for a block number.
    /// @param builder The address of the builder to commit to.
    /// @param blockNumber The block number for committing to the builder.
    function commitToBuilder(address builder, uint64 blockNumber) external {
        if (builderIsCommitted[msg.sender][blockNumber]) revert BuilderAlreadyCommitted();

        builderIsCommitted[msg.sender][blockNumber] = true;
        builderCommitted[msg.sender][blockNumber] = builder;

        emit NewBuilderCommitted(msg.sender, builder, blockNumber);
    }

    /// @notice This function is used to check whether a SignedBeaconBlock satisfies a commitment
    ///         to a builder the proposer of the block may have made.
    /// @param data The encoded SignedBeaconBlock.
    /// @return 1 if the builder is the same as the one committed to by the proposer, if any, 0 otherwise.
    ///         If no commitment was made, the commitment is considered satisfied and 1 is returned.
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

    /// @dev Sets the address of the commitment manager contract. Can only be called by the contract owner.
    /// @param newCommitmentManagerAddress The address of the new commitment manager contract.
    function setCommitmentManager(address newCommitmentManagerAddress) external onlyOwner {
        _setCommitmentManager(newCommitmentManagerAddress);
    }
}
