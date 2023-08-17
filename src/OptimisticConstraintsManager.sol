// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

//import "uma/core/optimistic-oracle-v3/implementation/OptimisticOracleV3.sol";
import "./BaseConstraintsManager.sol";

import "./lib/types.sol";
import "./lib/Lib.sol";

struct Request {
    bytes input;
    uint256 timestamp;
    bool successfullyChallenged;
    function (bool) external callback;
    bytes32 constraintsRoot;
}

contract OptimisticConstraintsManager is BaseConstraintsManager {
    using ConstraintsLib for Constraint;
    using ConstraintsLib for Constraint[];

    uint256 public constant CONSTRAINT_GAS_LIMIT = 50000;

    uint256 public constant LIVENESS = 1 hours;

    Request[] public requests;

    error ChallengeFailed();

    constructor(address constraintsAdder) BaseConstraintsManager(constraintsAdder) {}

    function areConstraintsAllSatisfied(bytes memory input, function (bool) external callback) external nonReentrant {
        Request memory request = Request({
            input: input,
            timestamp: block.timestamp,
            successfullyChallenged: false,
            callback: callback,
            constraintsRoot: keccak256(abi.encode(_constraints))
        });

        requests.push(request);
    }

    function _areConstraintsAllSatisfied(bytes memory input) internal pure override returns (bool satisfied) {
        assert(false); // TODO: implement
    }

    function challenge(uint256 id, Constraint[] calldata constraints, Constraint memory constraint) external {
        require(requests[id].timestamp - block.timestamp <= LIVENESS);
        require(keccak256(abi.encode(constraints)) == requests[id].constraintsRoot);
        require(!requests[id].successfullyChallenged);

        if (!constraint.isSatisfied(requests[id].input, CONSTRAINT_GAS_LIMIT)) revert ChallengeFailed();
        requests[id].successfullyChallenged = true;
        settle(id);
    }

    function settle(uint256 id) public {
        require(requests[id].timestamp - block.timestamp > LIVENESS);

        requests[id].callback(!requests[id].successfullyChallenged);
    }
}
