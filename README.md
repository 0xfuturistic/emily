# Emily: A Framework for Credible Commitments on Ethereum

Emily is a framework for implementing credible commitments on the Ethereum blockchain. Credible commitments are a concept from game theory that allow for the creation of binding agreements between parties, even in situations where there is a lack of trust.

Emily is designed to be a flexible and extensible framework that can be used to implement a wide range of credible commitment mechanisms. It is built on top of the Ethereum blockchain, which provides a secure and decentralized platform for executing smart contracts.

One of the key innovations of Emily is its use of a screener to enforce credible commitments. The screener is a smart contract that acts as a trusted third party, verifying that all parties to a commitment have fulfilled their obligations. This allows for the creation of binding agreements that are enforceable on the blockchain.

Emily is also designed to be highly modular, with a range of different components that can be combined to create custom credible commitment mechanisms. These components include:

- ERC-4337 entry point: A standard interface for interacting with Emily contracts.
- Account: A token-bound account that implements credible commitments using a screener.
- Screener: A smart contract that acts as a trusted third party to enforce credible commitments.
- AccountGuardian: A contract that can be used to manage the ownership of token-bound accounts.
- IAccountGuardian: An interface for interacting with the AccountGuardian contract.
- IERC6551Account: An interface for interacting with token-bound accounts.
