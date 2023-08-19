// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IntentManager.sol";

struct Claim {
    IntentManager.Intent intent;
    bytes data;
}

enum ClaimStatus {
    INACTIVE,
    ACTIVE
}

type ClaimId is uint256;

library LibClaim {
    function id(Claim memory claim) internal pure returns (ClaimId id_) {
        id_ = ClaimId.wrap(uint256(keccak256(abi.encode(claim))));
    }
}

contract OptimisticIntentManager is IntentManager {
    using LibClaim for Claim;

    mapping(Intent => function (bytes memory) view external) public _inverseRelationships;

    mapping(ClaimId => ClaimStatus) public _status;

    constructor(address initialOwner) IntentManager(initialOwner) {}

    function _assertValidity(Intent intent, bytes calldata data) internal override {
        (, ClaimId claimId) = _makeClaim(intent, data);
        _status[claimId] = ClaimStatus.ACTIVE;
        super._assertValidity(intent, data);
    }

    function _makeClaim(Intent intent, bytes calldata data)
        internal
        pure
        returns (Claim memory claim, ClaimId claimId)
    {
        claim = Claim({intent: intent, data: data});
        claimId = claim.id();
    }

    function _challenge(Claim memory claim) internal returns (ClaimId claimId) {
        require(_status[claimId = claim.id()] == ClaimStatus.ACTIVE, "OptimisticIntentManager: claim is not active");
        _status[claimId] = ClaimStatus.INACTIVE;
        _inverseRelationships[claim.intent](claim.data);
    }
}
