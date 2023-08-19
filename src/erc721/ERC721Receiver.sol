// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "solhooks/Hooks.sol";
import "../IntentManager.sol";

contract ERC721ReceiverIntentManager is IERC721Receiver, IntentManager, Hooks {
    constructor(address initialOwner) IntentManager(initialOwner) {}

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        preHook(
            this.assertValidity,
            abi.encode(abi.encodeWithSelector(this.onERC721Received.selector, operator, from, tokenId), data)
        )
        returns (bytes4)
    {
        return this.onERC721Received.selector;
    }
}
