# :magic_wand: Emily: A Protocol for Credible Commitments

![Alt Text](cover.png)

Emily offers a robust and efficient way for users to make commitments on Ethereum that can later be checked on arbitrary input. For a quick look into how leveraging Emily looks like, checkout the sample [PBS commitment](src/samples/CommitmentPBS.sol).

## Core Components
- **Commitment Manager**: Central smart contract that orchestrates the commitment process.
- **Commitment Structure**: Defines the properties of a commitment.
- **Commitment Library**: Contains methods for evaluating and finalizing commitments.

### Commitment Manager
The Commitment Manager is a smart contract that serves as the backbone of Emily. It performs two key functions:

1. **Creating Commitments**: Allows any EVM address to make new commitments.
2. **Evaluating Commitments**: Checks if a given value satisfies the conditions of a user’s commitments.
Users can create commitments without incurring gas costs by utilizing EIP712 signatures. Multiple commitments can also be bundled and submitted simultaneously.

### Commitment Structure
A commitment is characterized by two main elements:

1. **Target**: Specifies the subject matter of the commitment, similar to the concept of ‘scope’ in constraint satisfaction problems.
2. **Indicator Function**: A function that returns ‘1’ if the commitment is satisfied by a given value, and ‘0’ otherwise.
```solidity
struct Commitment {
    uint256 timestamp;
    function (bytes memory) external view returns (uint256) indicatorFunction;
}
```
It is with the indicator function that the commitment extensionally defines the subset of values that satisfies it.

### Commitment Library: CommitmentsLib
This library contains methods for:

1. Evaluating Commitments: Checks if a given value satisfies an array of commitments.
2. Finalizing Commitments: Determines if a commitment is finalized.
```solidity
library CommitmentsLib {
    function areCommitmentsSatisfiedByValue(Commitment[] memory commitments, bytes calldata value) public view returns (bool);
    function isFinalized(Commitment memory commitments) public view returns (bool finalized);
}
```
Currently, commitments are only considered probably finalized by checking if some amount of time has passed since the commitment was included. This, however, is not ideal. In practice, a better option may be for the protocol to verify a proof for the commitment’s finalization.

### Resource Management
Managing computational resources is a challenge due to the EVM’s gas-based operation. To prevent abuse, Emily allocates a fixed amount of gas for evaluating any user’s array of commitments. This ensures that computational resources are capped, bounding the worst-case scenario for distributed validators.

## :bug: Integrating Emily into Smart Contracts
Smart contracts that wish to enforce commitments can utilize a special modifier called Screen after inheriting from Screener.sol. This modifier enables functions to validate whether user actions meet the commitments of their originator.

For a practical example of how this works, refer to the sample implementation for PBS in the repository under samples/PEPC.sol, which implements PBS in terms of commitments.

### Account Abstraction (ERC4337)
The repository also includes an example that integrates commitments into ERC4337 accounts. Specifically, it screens user operations to ensure they satisfy the sender’s commitments.

As part of account abstraction, ERC4337 accounts can self-declare the contract responsible for their signature aggregator. The signature aggregator, not the account, is the one that implements the logic for verifying signatures, which can be arbitrary.

In the implementation below, the sample BLS signature aggregator has been extended to enforce commitments on user operations. In practice, a screening function is used to enforce commitments.

Here’s what integrating commitments into a SignatureAggregator looks like. Notice the that the only change is the addition of the modifier Screen.

```solidity
/**
* validate signature of a single userOp
* This method is called after EntryPoint.simulateValidation() returns an aggregator.
* First it validates the signature over the userOp. then it return data to be used when creating the handleOps:
* @param userOp the userOperation received from the user.
* @return sigForUserOp the value to put into the signature field of the userOp when calling handleOps.
*    (usually empty, unless account and aggregator support some kind of "multisig"
*/

function validateUserOpSignature(UserOperation calldata userOp)
    external
    view
    Screen(userOp.sender, this.validateUserOpSignature.selector, abi.encode(userOp))
    returns (bytes memory sigForUserOp)
{
    uint256[2] memory signature = abi.decode(userOp.signature, (uint256[2]));
    uint256[4] memory pubkey = getUserOpPublicKey(userOp);
    uint256[2] memory message = _userOpToMessage(userOp, _getPublicKeyHash(pubkey));

    require(BLSOpen.verifySingle(signature, pubkey, message), "BLS: wrong sig");
    return "";
}
```

### Token Bound Accounts (ERC6551)
The same commitment-enforcing logic has been applied to token-bound accounts, which is carried out by a slight modification in the executeCall function. Notice the modifier.

```solidity
/// @dev executes a low-level call against an account if the caller is authorized to make calls
function executeCall(address to, uint256 value, bytes calldata data)
    external
    payable
    onlyAuthorized
    onlyUnlocked
    Screen(address(this), this.executeCall.selector, abi.encode(to, value, data))
    returns (bytes memory)
{
    emit TransactionExecuted(to, value, data);

    _incrementNonce();

    return _call(to, value, data);
}
```
This change ensures that whenever a call is executed by the account, it satisfies the account’s commitments.

## 🎬 Behind the scenes
What happens after a function that imports Screen is called? The Screen modifier is invoked, which in turn calls the Commitment Manager to check if the user’s commitments are satisfied. The Commitment Manager then calls the Commitment Library to evaluate the commitments. If the commitments are satisfied, the function is executed. Otherwise, the function reverts.

![Alt Text](swimlanes.png)