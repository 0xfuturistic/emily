// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SoulboundERC721 is ERC721 {
    error OnlyMintingAllowed(address from, address to, uint256 firstTokenId, uint256 batchSize);

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    /// @dev Hook that is called before any token transfer. Reverts
    //       if the transfer is not a minting operation.
    /// @param from Address sending the tokens.
    /// @param to Address receiving the tokens.
    /// @param firstTokenId ID of the first token being transferred.
    /// @param batchSize Number of tokens being transferred.
    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize)
        internal
        override
    {
        if (from != address(0)) {
            revert OnlyMintingAllowed(from, to, firstTokenId, batchSize);
        }
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }
}
