# Land & Property Registry

**Blockchain-Based Land Ownership Management System**

**Course:** Blockchain: Theory & Practices  
**University:** Duy Tan University (DTU)  
**Technology:** Solidity, Ethereum, Ganache, MetaMask, Ethers.js, Flask, Web3.py

---

## 1. Project Overview

Land & Property Registry is a blockchain-based application designed to manage land registration, property ownership transfers, and ownership history.

The system uses an Ethereum smart contract to store land records and manage ownership changes in a transparent and verifiable manner.

An authorized officer is responsible for registering land parcels and approving or rejecting ownership transfer requests. Landowners can request ownership transfers through a web interface connected to MetaMask.

The application also uses a Flask backend with Web3.py to retrieve land information and ownership history from the blockchain.

### Project Objectives

- Develop a land registration system using Solidity.
- Prevent duplicate land registration.
- Implement role-based authorization.
- Allow landowners to request ownership transfers.
- Allow authorized officers to approve or reject transfers.
- Maintain ownership history on the blockchain.
- Integrate MetaMask with the frontend.
- Provide REST APIs using Flask and Web3.py.
- Test smart contract functionality.
- Analyze and optimize blockchain Gas consumption.

## 2. Technologies Used

| Technology | Purpose |
|---|---|
| Solidity 0.8.20 | Smart contract development |
| Remix IDE | Compilation, deployment and testing |
| Ganache Desktop | Local Ethereum blockchain |
| MetaMask | Wallet connection and transaction signing |
| Ethers.js v6 | Frontend blockchain interaction |
| HTML5 | Website structure |
| CSS3 | Website styling |
| JavaScript | Frontend functionality |
| Python | Backend programming |
| Flask | REST API framework |
| Web3.py | Backend blockchain communication |
| Flask-CORS | Cross-origin API requests |
| VS Code | Project development environment |

## 3. System Architecture

The application consists of four major components:

**1. Frontend**

The frontend provides a web-based dashboard for land registration, searching, ownership transfers, officer approval and ownership history.

It uses Ethers.js to connect to MetaMask and submit blockchain transactions.

**2. Backend**

The Flask backend provides REST APIs for retrieving land information, ownership history, blockchain status and contract configuration.

**3. Smart Contract**

The Solidity smart contract implements land registration, authorization, transfer requests, approval, rejection and ownership history.

**4. Blockchain Network**

Ganache provides a local Ethereum development environment where transactions and smart contract data are stored.

### Communication Flow

```text
                    User
                     |
                     v
             Web Application
            HTML / CSS / JS
                /       \
               /         \
              v           v
          MetaMask     Flask REST API
              |           |
          Ethers.js     Web3.py
              |           |
              v           v
          Ganache Local Blockchain
                     |
                     v
              LandRegistry.sol
```

All state-changing transactions are signed through MetaMask. Read-only land search and ownership history operations are performed through the Flask API.

## 4. Project Structure

```text
Land-Property-Registry/
|
|-- backend/
|   |-- app.py
|
|-- contracts/
|   |-- LandRegistry.sol
|   |-- LandRegistryOptimized.sol
|   |-- UnauthorizedUser.sol
|   |-- UnauthorizedUserOptimized.sol
|
|-- frontend/
|   |-- index.html
|   |-- style.css
|   |-- app.js
|   |-- LandRegistry_ABI.json
|
|-- tests/
|   |-- LandRegistry_test.sol
|   |-- LandRegistryOptimized_test.sol
|
|-- config.json
|-- requirements.txt
|-- README.md
```

The frontend files are stored in the `frontend/` directory.

## 5. Smart Contract Features

### 5.1 Land Registration

An authorized officer can register a land parcel using:

```solidity
registerLand(
    string landId,
    string location,
    uint256 area,
    address owner
)
```

The smart contract validates the information and prevents duplicate registration.

Each land record contains:

- Land ID
- Location
- Area
- Current owner

### 5.2 Land Search

Users can retrieve information about a registered land parcel using its Land ID.

The frontend uses the Flask API to query the blockchain without creating a state-changing transaction.

### 5.3 Ownership Transfer Request

Only the current owner can submit a request to transfer land ownership to another valid wallet address.

```solidity
requestTransfer(
    string landId,
    address newOwner
)
```

The request remains pending until the authorized officer processes it.

### 5.4 Transfer Approval

An authorized officer can approve a pending transfer using:

```solidity
approveTransfer(string landId)
```

When approved:

- The current owner is updated.
- The ownership history is extended.
- The pending transfer request is cleared.
- A transfer approval event is emitted.

### 5.5 Transfer Rejection

An authorized officer can reject a pending transfer:

```solidity
rejectTransfer(string landId)
```

When rejected, the pending request is cleared and ownership remains unchanged.

### 5.6 Ownership History

The application maintains historical ownership records on-chain.

```solidity
getOwnershipHistory(string landId)
```

Each ownership record contains the owner's wallet address and the recorded timestamp.

### 5.7 Access Control

The application separates users into different roles.

| Role | Permissions |
|---|---|
| Officer | Register land, approve transfers, reject transfers |
| Landowner | Request transfers for owned land |
| Other users | Search land records and view ownership history |

Authorization is enforced by the smart contract, not only by the frontend interface.

## 6. Blockchain Configuration

The application uses Ganache Desktop as a local Ethereum blockchain.

### Local Network

| Parameter | Value |
|---|---|
| Network | Ganache Local |
| RPC URL | http://127.0.0.1:7545 |
| Chain ID | 1337 |
| Solidity Compiler | 0.8.20 |
| EVM Version | Paris |

### Configuration File

The project uses a shared `config.json` file in the root directory.

```json
{
  "rpcUrl": "http://127.0.0.1:7545",
  "chainId": 1337,
  "contractAddress": "0xc918a5AaD7Ee965dBcCca8f7961A7E8d7c208D25"
}
```

The Flask backend reads the configuration file.

The frontend obtains the contract address through the Flask endpoint:

```text
GET /api/config
```

This avoids maintaining separate hardcoded contract addresses in the frontend and backend.

**Important:** The provided contract address belongs to the existing local Ganache deployment. A different Ganache workspace or blockchain instance may require a new deployment and an updated contract address.

## 7. Installation and Setup

### Requirements

Install the following software:

- Visual Studio Code
- Python 3
- Ganache Desktop
- MetaMask browser extension
- VS Code Live Server extension
- A modern web browser

### Step 1: Open the Project

Open the `Land-Property-Registry` folder in Visual Studio Code.

### Step 2: Start Ganache

Launch Ganache Desktop.

Open the existing workspace:

```text
elfin-front
```

Verify the network configuration:

```text
RPC URL: http://127.0.0.1:7545
Chain ID: 1337
```

Do not use a new Ganache workspace when attempting to access the existing deployed smart contract and historical data.

### Step 3: Install Python Dependencies

Open a terminal in the project root directory and run:

```bash
python -m pip install -r requirements.txt
```

### Step 4: Start the Flask Backend

Run:

```bash
python backend/app.py
```

The backend should start on:

```text
http://127.0.0.1:5000
```

Verify the blockchain connection using:

```text
http://127.0.0.1:5000/api/status
```

The response should indicate that the backend is connected to Ganache.

### Step 5: Open the Frontend

In VS Code:

1. Open `frontend/index.html`.
2. Right-click the file.
3. Select **Open with Live Server**.

Example URL:

```text
http://127.0.0.1:5500/frontend/index.html
```

The actual Live Server port may vary.

### Step 6: Connect MetaMask

1. Open MetaMask.
2. Select Ganache Local.
3. Verify Chain ID 1337.
4. Select the appropriate imported account.
5. Click **Connect MetaMask** on the website.

The website should display the connected wallet and load blockchain statistics.

### Important Runtime Notes

The current project requires:

- Ganache to remain running.
- Flask to remain running for REST API requests.
- MetaMask to use the correct Ganache network.
- The deployed contract address and ABI to match.

The website cannot perform blockchain transactions when the local Ganache network is unavailable.

## 8. REST API

The Flask backend provides the following endpoints.

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/status` | Check blockchain connection |
| GET | `/api/config` | Retrieve network and contract configuration |
| GET | `/api/lands/<land_id>` | Retrieve land information |
| GET | `/api/lands/<land_id>/history` | Retrieve ownership history |

### Example: Retrieve Land Information

```text
GET http://127.0.0.1:5000/api/lands/LAND003
```

### Example: Retrieve Ownership History

```text
GET http://127.0.0.1:5000/api/lands/LAND003/history
```

These APIs perform read-only operations.

Transactions such as registration, transfer requests, approval and rejection are executed through Ethers.js and MetaMask.

## 9. Automated Smart Contract Testing

Smart contract tests were executed using Remix Solidity Unit Testing.

Two implementations were tested:

1. `LandRegistry.sol`
2. `LandRegistryOptimized.sol`

### Test Results

| Smart Contract | Passed | Failed |
|---|---:|---:|
| LandRegistry.sol | 8 | 0 |
| LandRegistryOptimized.sol | 8 | 0 |
| **Total** | **16** | **0** |

### Test Scenarios

| No. | Test Scenario |
|---|---|
| 1 | Prevent duplicate land registration |
| 2 | Reject unauthorized land registration |
| 3 | Reject unauthorized transfer requests |
| 4 | Verify successful ownership transfer |
| 5 | Reject unauthorized transfer approval |
| 6 | Verify transfer request rejection |
| 7 | Verify ownership history |
| 8 | Reject invalid registration inputs |

The tests include successful transactions and expected failure cases.

### Running the Tests

1. Open Remix IDE.
2. Compile the relevant smart contract and test files.
3. Select the Solidity Unit Testing plugin.
4. Execute `LandRegistry_test.sol`.
5. Execute `LandRegistryOptimized_test.sol`.
6. Verify the test results.

The Solidity unit tests run in the Remix testing environment and do not require changing the existing Ganache deployment used by the website.

## 10. Practical Blockchain Demonstration

A complete registration and transfer workflow was successfully demonstrated using `LAND003`.

### Initial Registration

| Field | Value |
|---|---|
| Land ID | LAND003 |
| Location | Da Nang |
| Area | 150 m² |
| Initial Owner | Imported Account 2 |

Initial owner address:

```text
0xD488e93A66880Eb6bB25Bb066aD1863dAF58D440
```

The land parcel was registered by the authorized officer.

### Ownership Transfer

The original owner submitted a request to transfer LAND003 to Imported Account 3.

New owner address:

```text
0xd52c6AF1f99c390181149782367d331E1916ff8D
```

The transaction was confirmed through MetaMask.

The recorded Gas Used for the transfer request was:

```text
53,088 Gas
```

### Officer Approval

The authorized officer approved the ownership transfer.

After approval, the current owner of LAND003 changed to Imported Account 3.

### Ownership Verification

The Land Search function confirmed the updated owner.

The Transaction History function returned two ownership records:

1. Initial owner: Imported Account 2.
2. New owner: Imported Account 3.

This demonstration verified the integration between the frontend, MetaMask, Ganache, the Solidity smart contract and Flask API.

## 11. Gas Cost Analysis and Optimization

The project contains an optimized smart contract implementation:

```text
LandRegistryOptimized.sol
```

The optimized implementation uses Solidity custom errors to reduce the bytecode associated with error handling.

### Gas Measurements

| Operation | Original Contract | Optimized Contract |
|---|---:|---:|
| Contract Deployment | 1,785,200 Gas | 1,521,525 Gas |
| Register Land | 165,041 Gas | 165,041 Gas |
| Request Transfer | 53,076 Gas | 53,076 Gas |
| Approve Transfer | 86,642 Gas | 86,642 Gas |

The measurements were recorded in Remix IDE using Solidity 0.8.20, EVM target Paris, with the compiler optimizer disabled. The optimized implementation reduced deployment Gas by **263,675 Gas (approximately 14.77%)**.

The three measured successful transactions used the same Gas in both implementations. The benchmark does not include reverted transactions.

See [reports/gas-report.md](reports/gas-report.md) for the measurement method, detailed results and limitations.

## 12. Security and Validation

The application implements the following protections:

- Only an authorized officer can register land.
- Duplicate land registration is rejected.
- Invalid land area values are rejected.
- Invalid owner addresses are rejected.
- Only the current owner can request an ownership transfer.
- Transfers cannot be approved by unauthorized accounts.
- Pending transfer requests are managed through the smart contract.
- Ownership records are stored on-chain.
- Transactions must be signed through MetaMask.

The project is an academic prototype running on a local blockchain. It is not intended for production land title registration.

Never publish private keys, seed phrases or wallet recovery information in the source code or repository.

## 13. Demonstration Plan

The application can be presented in a 10-minute demonstration.

| Duration | Activity |
|---|---|
| 1 minute | Introduction and system architecture |
| 2 minutes | Connect MetaMask and register a new parcel |
| 1 minute | Search the registered parcel |
| 2 minutes | Submit an ownership transfer request |
| 2 minutes | Approve the transfer as officer |
| 1 minute | Verify ownership and transaction history |
| 1 minute | Present testing results and Gas analysis |

A new unused Land ID should be selected for the live demonstration.

Each successful registration or transfer transaction modifies the persistent state of the current Ganache workspace.

## 14. Limitations

The current application is designed for educational and demonstration purposes.

Current limitations include:

- Dependency on the local Ganache environment.
- Manual wallet switching between user roles.
- No integration with an official land cadastral database.
- No production-grade identity verification.
- No public blockchain deployment.
- Limited search functionality using Land ID.
- No on-chain land record deletion mechanism.

Future development may include a public testnet deployment, improved identity verification, advanced land search, geographical data and enhanced audit functionality.

## 15. Conclusion

The Land & Property Registry project demonstrates how blockchain technology can support transparent and verifiable land ownership management.

The system successfully integrates Solidity smart contracts, Ganache, MetaMask, Ethers.js, Flask and Web3.py.

Core functionality includes land registration, ownership transfer requests, officer approval, land search and ownership history.

The automated tests passed for both the original and optimized smart contracts, and the practical LAND003 demonstration verified the primary blockchain transaction workflow.

The application provides a functional educational prototype and a foundation for further development of decentralized property management systems.

---

**Project:** Land & Property Registry  
**Course:** Blockchain: Theory & Practices  
**University:** Duy Tan University


