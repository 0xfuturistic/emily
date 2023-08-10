// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {BLS} from "erc4337/samples/bls/lib/hubble-contracts/contracts/libs/BLS.sol";
import {IAccount} from "erc4337/interfaces/IAccount.sol";
import {ERC6551AccountLib} from "erc6551/lib/ERC6551AccountLib.sol";

abstract contract CommitmentAccount is IAccount {
    type Commitment is bytes32;

    Commitment[] commitments;

    function validate(
        uint256[2] memory signature,
        uint256[4] memory pubkey,
        uint256[2] memory message
    ) external view {
        /// @dev we clone the array so that it is not modified by the validation
        Commitment[] storage _commitments = commitments;

        for (uint256 i = 0; i < _commitments.length; i++) {
            _validate(_commitments[i], signature, pubkey, message);
        }
    }

    function _validate(
        Commitment commitment,
        uint256[2] memory signature_,
        uint256[4] memory pubkey_,
        uint256[2] memory message_
    ) internal pure {}
}

library BLSOpen {
    address constant ERC6551_REGISTRY =
        0x02101dfB77FDE026414827Fdc604ddAF224F0921;

    address constant ERC6551_IMPLEMENTATION =
        0x02101dfB77FDE026414827Fdc604ddAF224F0921;

    address constant TOKEN_CONTRACT =
        0x02101dfB77FDE026414827Fdc604ddAF224F0921;

    function verifySingle(
        uint256[2] memory signature,
        uint256[4] memory pubkey,
        uint256[2] memory message
    ) external view returns (bool) {
        uint256[4][] memory pubkeys = new uint256[4][](1);
        uint256[2][] memory messages = new uint256[2][](1);
        pubkeys[0] = pubkey;
        messages[0] = message;
        (bool verified, bool callSuccess) = BLS.verifyMultiple(
            signature,
            pubkeys,
            messages
        );

        uint tokenId = uint(keccak256(abi.encodePacked(pubkey)));

        address account = ERC6551AccountLib.computeAddress(
            ERC6551_REGISTRY,
            ERC6551_IMPLEMENTATION,
            block.chainid,
            TOKEN_CONTRACT,
            tokenId,
            0
        );

        assert(account != address(0));

        return callSuccess && verified;
        // // NB: (result, success) opposite of `call` convention (success, result).
        // (bool verified, bool callSuccess) = BLS.verifySingle(
        //     signature,
        //     pubkey,
        //     message
        // );
        // return callSuccess && verified;
    }

    function verifyMultiple(
        uint256[2] memory signature,
        uint256[4][] memory pubkeys,
        uint256[2][] memory messages
    ) external view returns (bool) {
        (bool verified, bool callSuccess) = BLS.verifyMultiple(
            signature,
            pubkeys,
            messages
        );
        return callSuccess && verified;
    }

    function hashToPoint(
        bytes32 domain,
        bytes memory message
    ) external view returns (uint256[2] memory) {
        return BLS.hashToPoint(domain, message);
    }

    function isZeroBLSKey(uint256[4] memory blsKey) public pure returns (bool) {
        bool isZero = true;
        for (uint256 i = 0; isZero && i < 4; i++) {
            isZero = (blsKey[i] == 0);
        }
        return isZero;
    }
}
