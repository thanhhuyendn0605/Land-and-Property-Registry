# LAND & PROPERTY REGISTRY
### Blockchain-Based Land Ownership Management System

**FINAL PROJECT REPORT**

**Course:** Blockchain: Theory & Practices  
**University:** Duy Tan University (DTU)  
**Project:** Land & Property Registry  
**Smart Contract Language:** Solidity 0.8.20  
**Development Tools:** Remix IDE, Ganache, MetaMask, Ethers.js, Flask, Web3.py  
**Date:** November 2026

---

## 1. Introduction

### 1.1 Background

Land ownership management requires accurate records, reliable authorization, and transparent tracking of ownership changes. Traditional centralized systems depend on administrators and databases to maintain land registration information.

Blockchain technology provides an alternative approach by allowing transactions and ownership history to be recorded in a distributed, verifiable ledger.

Smart contracts can automatically enforce registration rules, validate ownership transfers, and restrict sensitive operations to authorized users.

This project develops a blockchain-based Land & Property Registry system using Solidity and a local Ethereum environment.

### 1.2 Project Objectives

The main objectives of this project are:

1. Register land parcels with unique identification numbers.
2. Prevent duplicate or invalid land registration.
3. Implement authorization for government officers and landowners.
4. Allow landowners to request ownership transfers.
5. Allow officers to approve or reject transfer requests.
6. Maintain ownership history on the blockchain.
7. Develop a web interface integrated with MetaMask.
8. Implement a Flask API for retrieving blockchain records.
9. Perform automated tests and analyze Smart Contract Gas consumption.

### 1.3 Project Scope

The system is an academic prototype running on Ganache Local Blockchain.

It demonstrates blockchain-based ownership management but does not integrate with official government cadastral databases, legal identity verification systems, or real property certificates.

## 2. System Architecture

### 2.1 Overview

The Land & Property Registry system includes four components:

- **Frontend:** HTML, CSS, JavaScript, and Ethers.js v6.
- **Wallet:** MetaMask for account management and transaction signing.
- **Backend:** Python Flask and Web3.py.
- **Blockchain:** Solidity Smart Contract deployed on Ganache.

The frontend interacts with the blockchain through two paths.

**Transaction processing:**

User → Web Interface → Ethers.js → MetaMask → Ganache → Smart Contract

**Data retrieval:**

User → Web Interface → Flask REST API → Web3.py → Ganache → Smart Contract

The separation allows blockchain transactions to be signed by users while read-only information is retrieved through the backend.

### 2.2 Technologies

| Technology | Purpose |
|---|---|
| Solidity 0.8.20 | Smart Contract development |
| Remix IDE | Compilation, deployment, unit testing |
| Ganache Desktop | Local Ethereum blockchain |
| MetaMask | Wallet connection and signing |
| Ethers.js v6 | Frontend blockchain interactions |
| HTML / CSS / JavaScript | User interface |
| Python Flask | REST API backend |
| Web3.py | Blockchain data retrieval |
| JSON | Shared configuration and ABI |

### 2.3 Blockchain Configuration

The deployed application uses the following local network:

| Setting | Value |
|---|---|
| Blockchain | Ganache Local |
| RPC Endpoint | `http://127.0.0.1:7545` |
| Chain ID | 1337 |
| Solidity Compiler | 0.8.20 |
| Compiler EVM Target | Paris |

The main Smart Contract is deployed at:

`0xc918a5AaD7Ee965dBcCca8f7961A7E8d7c208D25`

The contract address and RPC settings are stored in `config.json`.

The Flask API exposes `/api/config`, allowing the frontend to retrieve the contract configuration without maintaining separate hardcoded addresses.

## 3. Smart Contract Design

### 3.1 Land Registration

The primary contract, `LandRegistry.sol`, maintains land records containing:

- Land ID
- Location
- Land area
- Current owner
- Registration status

The function `registerLand()` allows an authorized officer to register new parcels.

The contract rejects duplicate Land IDs, invalid areas, zero owner addresses, and unauthorized registration attempts.

These validations are enforced on-chain.

### 3.2 Ownership Transfer

Ownership transfers follow a request-and-approval process.

**Step 1 — Transfer Request**

The current landowner calls `requestTransfer()` with the Land ID and new owner address.

The Smart Contract verifies ownership and creates a pending request.

**Step 2 — Officer Review**

The authorized officer calls either:

- `approveTransfer()` to approve the request.
- `rejectTransfer()` to reject the request.

When approved, the Smart Contract updates the owner and records the new ownership information.

When rejected, the pending request is cleared without modifying the current owner.

### 3.3 Ownership History

The `getOwnershipHistory()` function returns a sequence of historical ownership records.

Each record contains an Ethereum address and a blockchain timestamp.

This enables users to verify both the original owner and subsequent ownership changes.

### 3.4 Access Control and Events

The system distinguishes between an officer, the current landowner, and other users.

| Operation | Authorized User |
|---|---|
| Register Land | Officer |
| Request Transfer | Current Landowner |
| Approve Transfer | Officer |
| Reject Transfer | Officer |
| Search Land | Any User |
| View Ownership History | Any User |

The Smart Contract emits four events:

`LandRegistered`, `TransferRequested`, `TransferApproved`, and `TransferRejected`.

These events also support Dashboard statistics and transaction monitoring.

## 4. Implementation and Practical Demonstration

The implementation was verified using the registered land parcel `LAND003`.

### 4.1 Land Registration

The authorized officer registered the following parcel:

| Field | Value |
|---|---|
| Land ID | LAND003 |
| Location | Da Nang |
| Area | 150 m² |
| Initial Owner | Imported Account 2 |

Initial owner address:

`0xD488e93A66880Eb6bB25Bb066aD1863dAF58D440`

After registration, the Land Search function retrieved the record successfully through Flask API.

This confirmed that the new land information had been stored on the blockchain.

### 4.2 Ownership Transfer Request

Imported Account 2, the initial owner, submitted an ownership transfer request to Imported Account 3.

New owner address:

`0xd52c6AF1f99c390181149782367d331E1916ff8D`

MetaMask signed and submitted the transaction.

The transaction completed successfully, consuming **53,088 Gas** on the existing Ganache deployment.

The request remained pending until officer approval.

### 4.3 Officer Approval

The officer used Imported Account 1 to approve the LAND003 transfer request.

After approval, Land Search returned Imported Account 3 as the current owner.

The updated ownership information confirmed that the transfer had been processed successfully.

### 4.4 Ownership History Verification

The Transaction History interface returned two ownership records.

| Record | Owner | Recorded At |
|---|---|---|
| #1 | Imported Account 2 | 24/11/2026 18:12:40 |
| #2 | Imported Account 3 | 24/11/2026 18:16:10 |

The original ownership record remained available after the transfer.

This result demonstrated the Smart Contract's ability to maintain historical ownership information.

### 4.5 Frontend and API Verification

The following components were verified through the website:

| Component | Result |
|---|---|
| MetaMask Connection | PASS |
| Dashboard Statistics | PASS |
| Land Registration | PASS |
| Land Search API | PASS |
| Ownership Transfer Request | PASS |
| Officer Approval | PASS |
| Ownership History API | PASS |
| Shared Configuration API | PASS |

The LAND003 demonstration confirmed the integration of the frontend, MetaMask, Flask, Web3.py, Ganache, and Solidity Smart Contract.

## 5. Testing and Gas Cost Analysis

### 5.1 Automated Unit Testing

Two implementations were tested using Remix Solidity Unit Testing:

- `LandRegistry.sol`
- `LandRegistryOptimized.sol`

The test suites included duplicate registration, unauthorized operations, successful transfers, rejection handling, ownership-history verification, and invalid input validation.

**Automated Test Results**

| Smart Contract | Passed | Failed |
|---|---:|---:|
| LandRegistry.sol | 8 | 0 |
| LandRegistryOptimized.sol | 8 | 0 |
| **Total** | **16** | **0** |

All recorded unit tests passed.

The automated tests were executed separately from the website's Ganache deployment.

These results verify the tested functional behavior, but do not constitute a comprehensive security audit.

### 5.2 Gas Optimization Technique

The original implementation uses string-based revert messages for validation.

The optimized implementation uses Solidity **Custom Errors**.

For example, instead of a string-based authorization error, the optimized contract defines an error and reverts using its selector.

Custom Errors can reduce compiled bytecode size and deployment Gas because they avoid embedding lengthy error messages in the contract bytecode.

However, the optimization does not necessarily reduce Gas on successful transaction paths.

### 5.3 Gas Measurement Method

Gas measurements were performed using Remix IDE with Solidity Compiler 0.8.20, EVM target Paris, and compiler optimization disabled.

Both Smart Contracts were deployed in Remix VM and tested separately.

Equivalent transaction inputs were used:

| Input | Value |
|---|---|
| Land ID | GAS001 |
| Location | Da Nang |
| Area | 200 m² |
| Initial Owner | Remix VM Account 1 |
| New Owner | Remix VM Account 2 |
| Officer | Remix VM Account 1 |

The comparison uses Remix's **Transaction Cost**, expressed in Gas units.

### 5.4 Gas Measurement Results

| Operation | Original Gas | Optimized Gas | Saving |
|---|---:|---:|---:|
| Contract Deployment | 1,785,200 | 1,521,525 | 263,675 |
| Register Land | 165,041 | 165,041 | 0 |
| Request Transfer | 53,076 | 53,076 | 0 |
| Approve Transfer | 86,642 | 86,642 | 0 |

**Deployment Gas Reduction**

Gas Saved = 1,785,200 − 1,521,525 = 263,675 Gas

Reduction Percentage = (263,675 / 1,785,200) × 100

**Result: approximately 14.77%**

### 5.5 Analysis

The optimized Smart Contract consumed approximately **14.77% less Gas during deployment**.

This is consistent with the reduction in compiled bytecode associated with replacing string-based revert messages with custom errors.

However, the three tested successful transactions consumed the same Gas in both implementations.

This result is reasonable because the custom error branches were not executed during successful operations.

Therefore, the optimization provides a demonstrated deployment advantage, but the measurements do not show reduced Gas for successful registration, transfer requests, or approval.

The cost of reverted transactions was not included in this benchmark.

The result should not be interpreted as a 14.77% reduction in all blockchain transaction costs.

## 6. Conclusion and Future Development

### 6.1 Achievements

The Land & Property Registry project successfully implemented the main functions of a blockchain-based land ownership management system.

The completed system supports land registration, duplicate prevention, authorization, transfer requests, officer approval, rejection, land search, and ownership-history retrieval.

The website integrates Solidity Smart Contracts with Ganache, MetaMask, Ethers.js, Flask, and Web3.py.

A practical demonstration using LAND003 confirmed successful registration, ownership transfer, and historical record retrieval.

Both contract implementations passed eight automated tests each, for a total of **16 passing test executions**.

The Gas analysis also demonstrated a **14.77% deployment Gas reduction** in the optimized contract.

### 6.2 Limitations

The current application has several limitations:

- It operates on a local Ganache blockchain.
- Account roles are managed through Ethereum wallet addresses.
- It has no integration with official property databases.
- It does not provide legal identity verification.
- It has limited land-search functionality.
- It is not intended for production or legally binding land registration.

### 6.3 Future Development

Possible improvements include:

- Deployment to an Ethereum public testnet.
- Stronger role management and identity verification.
- Enhanced property information and search capabilities.
- Improved transaction monitoring and user notifications.
- Integration with geographic or cadastral information systems.
- Additional security and Gas optimization testing.

### 6.4 Final Conclusion

The project demonstrates how Solidity Smart Contracts can enforce land registration rules, control ownership transfers, and retain verifiable ownership history.

The successful practical workflow, automated unit tests, and Gas measurements establish a functional educational prototype of blockchain-based property management.

---

## References

1. Solidity Documentation — https://docs.soliditylang.org/
2. Ethereum Documentation — https://ethereum.org/developers/
3. Remix IDE — https://remix.ethereum.org/
4. MetaMask Developer Documentation — https://docs.metamask.io/
5. Ethers.js Documentation — https://docs.ethers.org/v6/
6. Flask Documentation — https://flask.palletsprojects.com/
7. Web3.py Documentation — https://web3py.readthedocs.io/

---

**Supporting Project Files**

- `README.md` — Installation and usage guide
- `reports/test-results.md` — Automated and practical test results
- `reports/gas-report.md` — Gas Cost Analysis
- `reports/gas-report.json` — Structured Gas measurements
- `contracts/` — Solidity source code
- `tests/` — Automated tests
- `frontend/` — Web interface
- `backend/` — Flask REST API

**End of Report**

