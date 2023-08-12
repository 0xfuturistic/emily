// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseAccount, UserOperation} from "erc4337/core/BaseAccount.sol";

struct Commitment {
    function (bytes memory) external view prove;
}

/// @title CommitmentAccount
/// @dev Contract for managing user commitments and validating user operations.
abstract contract CommitmentsAccount is BaseAccount {
    /// @dev Validates user operation and checks if the user can prove the commitments.
    /// @param userOp User operation to be validated.
    /// @param userOpHash Hash of the user operation.
    /// @param missingAccountFunds Amount of missing account funds.
    /// @return validationData Returns validation data.
    function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        virtual
        override
        returns (uint256 validationData)
    {
        _requireFromEntryPoint();
        validationData = _validateSignature(userOp, userOpHash);
        _validateNonce(userOp.nonce);
        _payPrefund(missingAccountFunds);

        /// @dev We first check if the user has enough funds to pay for the worst case resource usage.
        //       That is, we assume that the user will prove the most expensive series of commitments.
        uint256 gasPreValiation;
        require(
            address(this).balance >= (gasPreValiation = gasleft()) * tx.gasprice,
            "Not enough eth for worst case validation"
        );

        /// @dev We now check if the user can prove the commitments. We use staticcall as a proxy so
        //       that the main call doesn't revert if proving fails without having reimbursed the gas
        ///      used for validation.
        (bool success,) = address(this).staticcall(
            abi.encodeWithSelector(
                this.proveUserCommitments.selector,
                userOp.sender,
                abi.encode(userOp, userOpHash, missingAccountFunds, validationData)
            )
        );

        /// @dev If the user can't prove the commitments, we refund the user for the gas used for validation.
        ///      This is done as an alternative to reverting the transaction and msg.sender incurring the
        ///      opportunity cost from the resources incurred by trying to prove the commitments on behalf
        ///      of the user.
        if (!success) payable(msg.sender).transfer((gasPreValiation - gasleft()) * tx.gasprice);
    }

    /// @dev Sample implementation of what ProveUserCommitments could look like.
    /// @param user User address.
    /// @param extraData Extra data to be used for proving commitments.
    function proveUserCommitments(address user, bytes memory extraData) external view virtual {
        Commitment[] memory commitments = _getUserCommitments(user);
        for (uint256 i = 0; i < commitments.length; i++) {
            commitments[i].prove(extraData);
        }
    }

    /// @dev Gets user commitments.
    /// @param user User address.
    /// @return userCommitments Returns user commitments.
    function _getUserCommitments(address user) internal view virtual returns (Commitment[] memory);
}
