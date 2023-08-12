// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseAccount, UserOperation} from "erc4337/core/BaseAccount.sol";

/// @title CommitmentAccount
/// @dev Contract for managing user commitments and validating user operations.
abstract contract CommitmentsAccount is BaseAccount {
    /// @dev Validates user operation and checks if the user can evaluate the commitments.
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
        //       That is, we assume we will have to evaluate the longest series of commitments before
        //       reverting at the end.
        uint256 gasPreValiation;
        require(
            address(this).balance >= (gasPreValiation = gasleft()) * tx.gasprice,
            "Not enough eth for worst case validation"
        );

        /// @dev We now check if the user can evaluate the commitments. We use staticcall as a proxy so
        //       that we can reimburse msg.sender the gas even if evaluating the commitments fails.
        (bool success,) = address(this).staticcall(
            abi.encodeWithSelector(
                this.evaluateUserCommitments.selector,
                userOp.sender,
                abi.encode(userOp, userOpHash, missingAccountFunds, validationData)
            )
        );

        /// @dev If the user can't evaluate the commitments, we refund the user for the gas used for validation.
        ///      This is done as an alternative to reverting the transaction and msg.sender incurring the
        ///      opportunity cost from the resources incurred by trying to evaluate the commitments on behalf
        ///      of the user.
        if (!success) payable(msg.sender).transfer((gasPreValiation - gasleft()) * tx.gasprice);
    }

    /// @dev Sample implementation of what evaluateUserCommitments could look like.
    /// @param user User address.
    /// @param extraData Extra data to be used for evaluating the commitments commitments.
    function evaluateUserCommitments(address user, bytes memory extraData) external view virtual {
        function (bytes memory) external view[] memory commitments = _getUserCommitments(user);
        for (uint256 i = 0; i < commitments.length; i++) {
            commitments[i](extraData);
        }
    }

    /// @dev Gets the functions to evaluate a user's commitments
    /// @param user User address.
    /// @return userCommitments Returns the functions to evaluate each user's commitments
    function _getUserCommitments(address user)
        internal
        view
        virtual
        returns (function (bytes memory) external view[] memory userCommitments);
}
