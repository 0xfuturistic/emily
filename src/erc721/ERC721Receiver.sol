// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "../IntentManager.sol";

contract ERC721ReceiverIntentManager is IERC721Receiver, IntentManager {
    constructor(address initialOwner) IntentManager(initialOwner) {}

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        Intent intent =
            Intent.wrap(keccak256(abi.encodeWithSelector(this.onERC721Received.selector, operator, from, tokenId)));
        _assertValidity(intent, data);
        return this.onERC721Received.selector;
    }
}
