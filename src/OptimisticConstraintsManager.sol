// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./BaseConstraintsManager.sol";
import "./lib/types.sol";
import "./lib/Lib.sol";

struct Request {
    bytes input;
    uint256 timestamp;
    bool successfullyChallenged;
    function (bool) external callback;
    bytes32 constraintsRoot;
    bool settled;
}

/// @title OptimisticConstraintsManager
/// @dev Base contract that implements a manager for optimistic constraint satisfaction. Requests are submitted with
///      a callback function, which will be called once the request has been evaluated. Validity of the request is
///      guaranteed for the set amount of liveness time. Clients can submit a set of constraints that, if unsatisfied,
///      will challenge and cancel the request.
contract OptimisticConstraintsManager is BaseConstraintsManager {
    using ConstraintsLib for Constraint;
    using ConstraintsLib for Constraint[];

    /// @dev The maximum gas limit that constraints are allowed to consume during their evaluation
    uint256 public constant CONSTRAINT_GAS_LIMIT = 50000;

    /// @dev The time until a request is considered valid if not successfully challenged
    uint256 public constant LIVENESS = 1 hours;

    Request[] public requests;

    /// @dev Error thrown if a challenge is unsuccessfully resolved
    error ChallengeFailed();

    constructor(address constraintsAdder) BaseConstraintsManager(constraintsAdder) {}

    /// @notice Used to notify the manager of a new request.
    /// @param input The input data to the constraints system
    /// @param callback A callback function that will be called when the manager finishes evaluating the constraints
    function areConstraintsAllSatisfied(bytes memory input, function (bool) external callback) external nonReentrant {
        Request memory request = Request({
            input: input,
            timestamp: block.timestamp,
            successfullyChallenged: false,
            callback: callback,
            constraintsRoot: keccak256(abi.encode(_constraints)),
            settled: false
        });

        requests.push(request);
    }

    /// @notice Implementation function to check if the constraints provided are satisfied.
    /// @param input The input data to the constraints system
    /// @return satisfied Whether the provide constraints were all satisfied or not
    function _areConstraintsAllSatisfied(bytes memory input) internal pure override returns (bool satisfied) {
        assert(false); // TODO: implement
    }

    /// @notice Submit a challenge to the validity of the provided constraints in a request. If satisfied, the
    ///         request is cancelled and the callback of the requester is not executed.
    /// @param id The ID of the request being challenged
    /// @param constraints The set of constraints currently in the manager's state
    /// @param constraint The single constraint that invalidates the full set of the challenged request, if existent
    function challenge(uint256 id, Constraint[] calldata constraints, Constraint memory constraint) external {
        require(requests[id].timestamp - block.timestamp <= LIVENESS);
        require(keccak256(abi.encode(constraints)) == requests[id].constraintsRoot);
        require(!requests[id].successfullyChallenged);

        if (!constraint.isSatisfied(requests[id].input, CONSTRAINT_GAS_LIMIT)) revert ChallengeFailed();
        requests[id].successfullyChallenged = true;
        settle(id);
    }

    /// @notice Settle a validated request. If the request has gone past the liveness period without a successful
    ///         challenge, its callback is executed with the value set to `true`. Otherwise, the callback is
    ///         executed with the value set to `false`
    /// @param id The ID of the request being challenged
    function settle(uint256 id) public {
        require(requests[id].timestamp - block.timestamp > LIVENESS || requests[id].successfullyChallenged);
        require(!requests[id].settled);
        requests[id].settled = true;
        requests[id].callback(!requests[id].successfullyChallenged);
    }
}
