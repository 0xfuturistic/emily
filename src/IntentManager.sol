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

    function assertValidity(bytes memory data) external virtual {
        (Intent intent, bytes memory intentData) = abi.decode(data, (Intent, bytes));
        _testConstraints(intent, intentData);
    }

    function _testConstraints(Intent intent, bytes memory data) internal view {
        _constraints[intent](data);
    }
}
