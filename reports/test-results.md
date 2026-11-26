
# SMART CONTRACT TESTING RESULTS

**Project:** Land & Property Registry  
**Course:** Blockchain: Theory & Practices  
**University:** Duy Tan University (DTU)  
**Solidity Version:** 0.8.20  
**Testing Tools:** Remix IDE, Ganache Desktop, MetaMask, Flask, Web3.py  
**Date:** November 24, 2026

---

## 1. Introduction

This document presents the testing results of the
Land & Property Registry blockchain application.

The purpose of testing is to verify the functionality,
access control, transaction processing, and ownership
history management implemented in the smart contracts.

The project includes two smart contract implementations:

1. LandRegistry.sol - Original implementation
2. LandRegistryOptimized.sol - Gas-optimized implementation

Testing was conducted using two approaches:

- Automated Solidity unit testing in Remix IDE.
- Practical end-to-end testing using the web application,
  MetaMask, Ganache Desktop, and Flask API.

Gas consumption was also measured and compared between
the original and optimized implementations.

## 2. Testing Environment

### 2.1 Automated Testing Environment

| Component | Configuration |
|---|---|
| Development Tool | Remix IDE |
| Solidity Compiler | 0.8.20 |
| Compiler EVM Target | Paris |
| Compiler Optimizer | Disabled (Gas benchmark) |
| Testing Tool | Solidity Unit Testing |
| Execution Environment | Remix VM |

Automated unit tests and Gas measurements were performed
in Remix, separately from the Ganache environment used
by the website.

### 2.2 Practical Testing Environment

| Component | Configuration |
|---|---|
| Blockchain | Ganache Desktop |
| Workspace | elfin-front |
| RPC URL | http://127.0.0.1:7545 |
| Chain ID | 1337 |
| Smart Contract | LandRegistry.sol |
| Frontend | HTML, CSS, JavaScript |
| Blockchain Library | Ethers.js v6 |
| Wallet | MetaMask |
| Backend | Python Flask |
| Blockchain API | Web3.py |

The practical demonstration used the existing deployed
contract on Ganache.

Contract address:

0xc918a5AaD7Ee965dBcCca8f7961A7E8d7c208D25

The website obtains this address from the shared
configuration through the Flask API.

## 3. Automated Unit Testing

### 3.1 Testing Objectives

The automated tests were designed to verify:

- Land registration validation.
- Duplicate land registration prevention.
- Officer authorization.
- Landowner authorization.
- Ownership transfer processing.
- Transfer request rejection.
- Ownership history management.
- Invalid input handling.

### 3.2 Test Files

The project contains two main unit test suites:

```text
tests/
├── LandRegistry_test.sol
└── LandRegistryOptimized_test.sol
```

Supporting contracts are used to simulate unauthorized
users when testing access control restrictions.

### 3.3 Automated Test Results

| Test Suite | Passed | Failed | Execution Time |
|---|---:|---:|---:|
| LandRegistry_test.sol | 8 | 0 | 1.12 seconds |
| LandRegistryOptimized_test.sol | 8 | 0 | 1.14 seconds |
| **Total** | **16** | **0** | — |

Both smart contract implementations passed all recorded
automated tests.

The total of 16 passing executions represents eight tests
for each implementation.

### 3.4 Detailed Test Scenarios

| No. | Test Scenario | Expected Result | Original | Optimized |
|---|---|---|---|---|
| 1 | Duplicate Registration | Reject duplicate Land ID | PASS | PASS |
| 2 | Unauthorized Registration | Reject non-officer registration | PASS | PASS |
| 3 | Unauthorized Transfer | Reject requests from non-owners | PASS | PASS |
| 4 | Successful Transfer | Update owner after approval | PASS | PASS |
| 5 | Unauthorized Approval | Reject approval by non-officers | PASS | PASS |
| 6 | Transfer Rejection | Clear request without changing owner | PASS | PASS |
| 7 | Ownership History | Return historical ownership records | PASS | PASS |
| 8 | Invalid Registration Inputs | Reject invalid land information | PASS | PASS |

### 3.5 Negative Test Cases

The project includes multiple expected-failure tests.

**Test Case 1: Duplicate Registration**

A land parcel with an existing Land ID cannot be
registered again.

Expected result: Transaction reverted.

Actual result: PASS.

**Test Case 2: Unauthorized Registration**

An unauthorized account attempts to register a
new land parcel.

Expected result: Transaction reverted.

Actual result: PASS.

**Test Case 3: Unauthorized Transfer Request**

An account that does not own the land attempts
to request ownership transfer.

Expected result: Transaction reverted.

Actual result: PASS.

**Test Case 4: Unauthorized Transfer Approval**

An account without officer privileges attempts
to approve a pending transfer.

Expected result: Transaction reverted.

Actual result: PASS.

**Test Case 5: Invalid Registration Inputs**

Invalid registration parameters are rejected
by the smart contract.

Expected result: Transaction reverted.

Actual result: PASS.

These tests demonstrate that the implemented validation
and authorization checks work for the tested scenarios.

They do not constitute a comprehensive smart contract
security audit.

## 4. Practical Blockchain Testing

A complete practical transaction workflow was performed
using the deployed LandRegistry smart contract.

The test land parcel was:

LAND003

### 4.1 Land Registration

The authorized officer registered LAND003 through
the website.

Registration data:

| Field | Value |
|---|---|
| Land ID | LAND003 |
| Location | Da Nang |
| Area | 150 m² |
| Initial Owner | Imported Account 2 |

Initial owner wallet:

```text
0xD488e93A66880Eb6bB25Bb066aD1863dAF58D440
```

After registration, the Land Search function successfully
retrieved the stored information through Flask API.

**Result: PASS**

### 4.2 Ownership Transfer Request

The original owner, Imported Account 2, submitted
a transfer request for LAND003.

Transfer destination:

Imported Account 3

New owner wallet:

```text
0xd52c6AF1f99c390181149782367d331E1916ff8D
```

The request was submitted using MetaMask.

The website displayed:

```text
Transaction successful! Gas used: 53088
```

The transaction was confirmed on Ganache.

The ownership transfer remained pending until
the authorized officer processed the request.

**Result: PASS**

### 4.3 Officer Approval

Imported Account 1, acting as the authorized officer,
approved the pending transfer request.

After approval:

- The pending request was processed.
- The current owner was changed.
- The ownership history was updated.
- The new owner became visible in Land Search.

**Result: PASS**

### 4.4 Land Search Verification

The website retrieved the updated LAND003 information
through Flask API.

Returned data:

```text
Land ID: LAND003
Location: Da Nang
Area: 150 m²

Current Owner:
0xd52c6AF1f99c390181149782367d331E1916ff8D
```

The current owner matched Imported Account 3.

This verified that the approved ownership transfer
was reflected in the blockchain state.

**Result: PASS**

### 4.5 Ownership History Verification

The Transaction History interface returned
two ownership records for LAND003.

| Record | Owner | Recorded At |
|---|---|---|
| #1 | Imported Account 2 | 24/11/2026 18:12:40 |
| #2 | Imported Account 3 | 24/11/2026 18:16:10 |

Ownership Record #1:

```text
Owner:
0xD488e93A66880Eb6bB25Bb066aD1863dAF58D440

Recorded At:
24/11/2026 18:12:40
```

Ownership Record #2:

```text
Owner:
0xd52c6AF1f99c390181149782367d331E1916ff8D

Recorded At:
24/11/2026 18:16:10
```

The original ownership record remained available
after the successful transfer.

**Result: PASS**

## 5. Backend API Testing

The Flask REST API was tested through browser requests
and the web interface.

### 5.1 Blockchain Status API

Endpoint:

```text
GET /api/status
```

Purpose:

Verify the Flask backend connection to Ganache.

The API successfully connected to Ganache when
the local blockchain was running.

**Result: PASS**

### 5.2 Contract Configuration API

Endpoint:

```text
GET /api/config
```

The browser Network panel confirmed an HTTP 200
response from the Flask API.

The endpoint returned the shared contract configuration
used by the website.

**Result: PASS**

### 5.3 Land Information API

Endpoint:

```text
GET /api/lands/LAND003
```

The API successfully retrieved:

- Land ID.
- Location.
- Area.
- Current owner.

**Result: PASS**

### 5.4 Ownership History API

Endpoint:

```text
GET /api/lands/LAND003/history
```

The API returned two historical ownership records.

**Result: PASS**

## 6. Frontend Integration Testing

The web interface was tested using MetaMask and
the existing Ganache deployment.

| Function | Result |
|---|---|
| Connect MetaMask | PASS |
| Load Blockchain Dashboard | PASS |
| Register Land | PASS |
| Search Land | PASS |
| Request Ownership Transfer | PASS |
| Approve Ownership Transfer | PASS |
| Retrieve Ownership History | PASS |
| Load Contract Configuration | PASS |

The transfer rejection flow was covered by automated
unit testing but was not separately demonstrated
through the redesigned frontend.

The practical website demonstration used the original
LandRegistry.sol implementation.

The optimized contract was tested separately.

## 7. Gas Cost Analysis Results

Gas consumption was measured for both contract
implementations using Remix IDE.

### 7.1 Measurement Configuration

| Parameter | Value |
|---|---|
| Solidity Compiler | 0.8.20 |
| Compiler EVM Target | Paris |
| Optimizer | Disabled |
| Execution Environment | Remix VM |
| Measurement Metric | Transaction Cost |
| Gas Unit | Gas |

Equivalent inputs were used for both implementations.

| Input | Value |
|---|---|
| Land ID | GAS001 |
| Location | Da Nang |
| Area | 200 m² |
| Initial Owner | Remix VM Account 1 |
| New Owner | Remix VM Account 2 |
| Officer | Remix VM Account 1 |

### 7.2 Gas Comparison

| Operation | Original Gas | Optimized Gas | Gas Saved | Reduction |
|---|---:|---:|---:|---:|
| Contract Deployment | 1,785,200 | 1,521,525 | 263,675 | 14.77% |
| Register Land | 165,041 | 165,041 | 0 | 0% |
| Request Transfer | 53,076 | 53,076 | 0 | 0% |
| Approve Transfer | 86,642 | 86,642 | 0 | 0% |

The values were recorded from the transaction
details displayed in Remix.

### 7.3 Deployment Gas Reduction

Original contract deployment:

1,785,200 Gas

Optimized contract deployment:

1,521,525 Gas

Gas saved:

```text
1,785,200 - 1,521,525 = 263,675 Gas
```

Reduction percentage:

```text
(263,675 / 1,785,200) * 100 = 14.77%
```

The optimized implementation reduced deployment
Gas consumption by approximately 14.77%.

### 7.4 Optimization Technique

The original contract uses string-based error
messages in require statements.

The optimized contract uses Solidity Custom Errors.

Custom errors can reduce compiled bytecode size
and deployment Gas.

However, successful transactions do not execute
the error-handling branches.

This explains why the three measured successful
transactions had identical Gas consumption.

### 7.5 Transaction Gas Comparison

**Register Land**

Original: 165,041 Gas

Optimized: 165,041 Gas

Saving: 0%

**Request Transfer**

Original: 53,076 Gas

Optimized: 53,076 Gas

Saving: 0%

**Approve Transfer**

Original: 86,642 Gas

Optimized: 86,642 Gas

Saving: 0%

The optimization demonstrated deployment savings,
but no reduction in these successful transaction paths.

### 7.6 Practical Ganache Gas Measurement

During the LAND003 demonstration on Ganache Desktop,
the original contract consumed:

**53,088 Gas**

for the successful transfer request.

This result is separate from the Remix VM benchmark,
which measured 53,076 Gas for requestTransfer.

The values come from different execution environments
and should not be treated as a direct comparison
between the original and optimized contracts.

### 7.7 Gas Analysis Conclusion

The optimized contract reduced Deployment Gas
by approximately 14.77%.

The three tested successful transactions consumed
identical Gas in both implementations.

The results demonstrate that Gas optimization
is operation-dependent.

The benchmark did not measure Gas consumption
of reverted transactions.

Detailed results are documented in:

- reports/gas-report.md
- reports/gas-report.json

## 8. Testing Evidence

Screenshots should be stored in:

```text
reports/screenshots/
```

Recommended evidence:

| File | Description |
|---|---|
| unit-test-original.png | Original contract, 8 PASS |
| unit-test-optimized.png | Optimized contract, 8 PASS |
| dashboard.png | Connected Dashboard |
| land003-search.png | LAND003 search result |
| land003-transfer.png | Successful transfer request |
| land003-history.png | Ownership history |
| gas-deploy-original.png | Original deployment Gas |
| gas-deploy-optimized.png | Optimized deployment Gas |
| gas-register.png | Land registration Gas |
| gas-transfer.png | Transfer request Gas |
| gas-approval.png | Transfer approval Gas |

These are suggested filenames for organizing
supporting screenshots.

The final submission should reference only the
screenshots actually saved in the project.

## 9. Testing Summary

| Testing Category | Result |
|---|---|
| Original Smart Contract Unit Tests | 8/8 PASS |
| Optimized Smart Contract Unit Tests | 8/8 PASS |
| Practical Land Registration | PASS |
| Practical Ownership Transfer Request | PASS |
| Practical Officer Approval | PASS |
| Practical Land Search | PASS |
| Practical Ownership History | PASS |
| Flask API Integration | PASS |
| MetaMask and Ganache Integration | PASS |
| Gas Comparison | Completed for 4 operations |

The test results confirm that the application's
main registration and ownership-transfer workflow
operated successfully in the tested environments.

## 10. Conclusion

The Land & Property Registry project successfully
completed the recorded automated unit tests and
practical blockchain verification.

Both smart contract implementations passed all eight
unit tests, resulting in:

**16 Passed / 0 Failed**

The practical demonstration using LAND003 confirmed
that the system could:

1. Register a new land parcel.
2. Submit an ownership transfer request.
3. Approve the transfer through an authorized officer.
4. Retrieve the updated land ownership information.
5. Preserve historical ownership records.

The Flask API successfully retrieved land information
and ownership history from Ganache.

Gas Cost Analysis was completed for four operations.

The optimized implementation demonstrated a
**14.77% reduction in deployment Gas**, while the
three tested successful transactions had identical
Gas costs.

These results support the functional validity
of the implemented academic prototype.

Further testing would be required before adapting
the system to a production environment.

---

**Supporting Files**

- README.md
- reports/final-report.md
- reports/gas-report.md
- reports/gas-report.json
- contracts/LandRegistry.sol
- contracts/LandRegistryOptimized.sol
- tests/LandRegistry_test.sol
- tests/LandRegistryOptimized_test.sol

**End of Testing Report**
