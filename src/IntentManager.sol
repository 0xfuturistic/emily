// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./lib/types.sol";

contract IntentManager is Ownable {
    mapping(Intent => function (bytes memory) external view) internal _constraints;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function setConstraint(Intent intent, function (bytes memory) external view constraint) public onlyOwner {
        _constraints[intent] = constraint;
    }

    function _assertValidity(Intent intent, bytes calldata data) internal virtual {
        _testConstraints(intent, data);
    }

    function _testConstraints(Intent intent, bytes calldata data) internal view {
        _constraints[intent](data);
    }
}
