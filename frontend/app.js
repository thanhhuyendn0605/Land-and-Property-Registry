
"use strict";

// ======================================
// LAND & PROPERTY REGISTRY
// CONFIGURATION
// ======================================

let CONTRACT_ADDRESS = null;

const CHAIN_ID = "0x539"; // Ganache Chain ID: 1337

const API_BASE_URL = "http://127.0.0.1:5000/api";

let provider = null;
let signer = null;
let contract = null;

const $ = (id) => document.getElementById(id);

function input(id) {
  return $(id).value.trim();
}

function showStatus(message, isError = false) {
  const element = $("status");
  element.textContent = message;
  element.style.color = isError ? "#b91c1c" : "#105765";
}

function handleError(error) {
  console.error(error);

  const message =
    error.reason ||
    error.shortMessage ||
    error.message ||
    "Unknown error";

  showStatus("Error: " + message, true);
}

function requireContract() {
  if (!contract) {
    throw new Error(
      "Connect MetaMask before continuing."
    );
  }

  return contract;
}

// ======================================
// 1. FLASK BACKEND API
// ======================================

async function fetchApi(path) {
  let response;

  try {
    response = await fetch(API_BASE_URL + path, {
      headers: {
        Accept: "application/json"
      }
    });
  } catch (error) {
    throw new Error(
      "Cannot connect to Flask API. " +
      "Please start Ganache and Flask server."
    );
  }

  let data;

  try {
    data = await response.json();
  } catch (error) {
    throw new Error(
      "Invalid response from Flask API."
    );
  }

  if (!response.ok) {
    throw new Error(
      data.error ||
      data.message ||
      "Flask API request failed."
    );
  }

  return data;
}

// ======================================
// 2. SIDEBAR NAVIGATION
// ======================================

function openPage(pageId) {
  showStatus("");
  document.querySelectorAll(".page").forEach((page) => {
    page.classList.toggle(
      "active",
      page.id === pageId
    );
  });

  document.querySelectorAll(".nav-link").forEach((button) => {
    const isActive =
      button.dataset.page === pageId;

    button.classList.toggle(
      "active",
      isActive
    );
  });

  window.scrollTo(0, 0);
}

document.querySelectorAll(".nav-link").forEach((button) => {
  button.addEventListener("click", () => {
    openPage(button.dataset.page);
  });
});

document.querySelectorAll("[data-go]").forEach((button) => {
  button.addEventListener("click", () => {
    openPage(button.dataset.go);
  });
});

// ======================================
// 3. METAMASK CONNECTION
// ======================================


async function loadBlockchainConfig() {
  const response = await fetch(
    API_BASE_URL + "/config"
  );

  if (!response.ok) {
    throw new Error("Cannot load blockchain configuration.");
  }

  const config = await response.json();

  if (!ethers.isAddress(config.contractAddress)) {
    throw new Error("Invalid contract address.");
  }

  if (Number(config.chainId) !== 1337) {
    throw new Error("Incorrect Ganache Chain ID.");
  }

  CONTRACT_ADDRESS = config.contractAddress;
}

async function connectWallet() {
  try {
    if (!window.ethereum) {
      throw new Error(
        "MetaMask extension was not detected."
      );
    }

    if (!window.ethers) {
      throw new Error(
        "Unable to load ethers.js."
      );
    }

    showStatus("Connecting to MetaMask...");
    await loadBlockchainConfig();
    const currentChain =
      await window.ethereum.request({
        method: "eth_chainId"
      });

    if (BigInt(currentChain) !== 1337n) {
      try {
        await window.ethereum.request({
          method: "wallet_switchEthereumChain",
          params: [
            {
              chainId: CHAIN_ID
            }
          ]
        });
      } catch (error) {
        if (error.code !== 4902) {
          throw error;
        }

        await window.ethereum.request({
          method: "wallet_addEthereumChain",
          params: [
            {
              chainId: CHAIN_ID,
              chainName: "Ganache Local",
              rpcUrls: [
                "http://127.0.0.1:7545"
              ],
              nativeCurrency: {
                name: "Ether",
                symbol: "ETH",
                decimals: 18
              }
            }
          ]
        });

        await window.ethereum.request({
          method: "wallet_switchEthereumChain",
          params: [
            {
              chainId: CHAIN_ID
            }
          ]
        });
      }
    }

    await window.ethereum.request({
      method: "eth_requestAccounts"
    });

    provider = new ethers.BrowserProvider(
      window.ethereum
    );

    signer = await provider.getSigner();

    const network = await provider.getNetwork();

    if (network.chainId !== 1337n) {
      throw new Error(
        "Please select Ganache Local."
      );
    }

    const response = await fetch(
      "./LandRegistry_ABI.json"
    );

    if (!response.ok) {
      throw new Error(
        "Cannot load LandRegistry_ABI.json"
      );
    }

    const abiFile = await response.json();

    const abi = Array.isArray(abiFile)
      ? abiFile
      : abiFile.abi;

    if (!Array.isArray(abi)) {
      throw new Error(
        "Invalid contract ABI format."
      );
    }

    const code = await provider.getCode(
      CONTRACT_ADDRESS
    );

    if (code === "0x") {
      throw new Error(
        "LandRegistry contract not found. " +
        "Check Ganache workspace."
      );
    }

    contract = new ethers.Contract(
      CONTRACT_ADDRESS,
      abi,
      signer
    );

    const address = await signer.getAddress();

    $("walletAddress").textContent =
      address.slice(0, 8) +
      "..." +
      address.slice(-6);

    $("connectionStatus").textContent =
      "Connected";

    showStatus(
      "Connected to Ganache Local successfully!"
    );

    await updateDashboard();

  } catch (error) {
    contract = null;

    $("connectionStatus").textContent =
      "Not connected";

    handleError(error);
  }
}

// ======================================
// 4. DASHBOARD STATISTICS
// ======================================

async function updateDashboard() {
  try {
    const c = requireContract();

    const blockNumber =
      await provider.getBlockNumber();

    $("currentBlock").textContent =
      blockNumber;

    const logs = await provider.getLogs({
      address: CONTRACT_ADDRESS,
      fromBlock: 0,
      toBlock: "latest"
    });

    const events = [];

    for (const log of logs) {
      try {
        const parsed =
          c.interface.parseLog(log);

        if (parsed) {
          events.push(parsed);
        }
      } catch {
        // Ignore unrecognized events.
      }
    }

    const eventNames = new Set(
      c.interface.fragments
        .filter(
          (fragment) =>
            fragment.type === "event"
        )
        .map(
          (fragment) => fragment.name
        )
    );

    function eventLandId(event) {
      const inputs = event.fragment.inputs;

      const index = inputs.findIndex(
        (item) => item.name === "landId"
      );

      if (index >= 0) {
        return String(event.args[index]);
      }

      const stringIndex =
        inputs.findIndex(
          (item) => item.type === "string"
        );

      return stringIndex >= 0
        ? String(event.args[stringIndex])
        : null;
    }

    const registered = new Set();
    const pending = new Set();

    let approved = 0;

    for (const event of events) {
      const landId = eventLandId(event);

      if (
        event.name === "LandRegistered" &&
        landId
      ) {
        registered.add(landId);
      }

      if (
        event.name === "TransferRequested" &&
        landId
      ) {
        pending.add(landId);
      }

      if (
        event.name === "TransferApproved"
      ) {
        approved++;

        if (landId) {
          pending.delete(landId);
        }
      }

      if (
        event.name === "TransferRejected" &&
        landId
      ) {
        pending.delete(landId);
      }
    }

    $("totalLands").textContent =
      eventNames.has("LandRegistered")
        ? registered.size
        : "—";

    $("totalApproved").textContent =
      eventNames.has("TransferApproved")
        ? approved
        : "—";

    const hasTransferEvents =
      eventNames.has("TransferRequested") &&
      eventNames.has("TransferApproved") &&
      eventNames.has("TransferRejected");

    $("totalPending").textContent =
      hasTransferEvents
        ? pending.size
        : "—";

  } catch (error) {
    console.error(
      "Dashboard error:",
      error
    );

    showStatus(
      "Connected, but dashboard statistics " +
      "could not be loaded.",
      true
    );
  }
}

// ======================================
// 5. BLOCKCHAIN TRANSACTIONS
// ETHERS.JS + METAMASK
// ======================================

async function sendTransaction(action) {
  try {
    const c = requireContract();

    showStatus(
      "Confirm the transaction in MetaMask..."
    );

    const tx = await action(c);

    showStatus(
      "Transaction submitted. " +
      "Waiting for confirmation..."
    );

    const receipt = await tx.wait();

    if (
      !receipt ||
      receipt.status !== 1
    ) {
      throw new Error(
        "Transaction failed."
      );
    }

    showStatus(
      "Transaction successful! Gas used: " +
      receipt.gasUsed.toString()
    );

    await updateDashboard();

  } catch (error) {
    handleError(error);
  }
}

// ======================================
// 6. REGISTER LAND
// ======================================

async function registerLand() {
  const landId = input("landId");
  const location = input("location");
  const area = input("area");
  const owner = input("owner");

  if (
    !landId ||
    !location ||
    !area ||
    !owner
  ) {
    showStatus(
      "Please complete all required fields.",
      true
    );

    return;
  }

  if (!/^[1-9]\d*$/.test(area)) {
    showStatus(
      "Land area must be a positive integer.",
      true
    );

    return;
  }

  if (!ethers.isAddress(owner)) {
    showStatus(
      "Invalid owner wallet address.",
      true
    );

    return;
  }

  await sendTransaction(
    (c) =>
      c.registerLand(
        landId,
        location,
        BigInt(area),
        owner
      )
  );
}

// ======================================
// 7. LAND SEARCH VIA FLASK API
// ======================================

async function searchLand() {
  try {
    const landId = input("searchId");

    if (!landId) {
      throw new Error(
        "Please enter a Land ID."
      );
    }

    showStatus(
      "Loading land record from Flask API..."
    );

    const land = await fetchApi(
      "/lands/" +
      encodeURIComponent(landId)
    );

    $("landResult").textContent =
      "Land ID: " + land.landId + "\n" +
      "Location: " + land.location + "\n" +
      "Area: " + land.area + " m²\n" +
      "Current Owner: " + land.owner;

    showStatus(
      "Land record retrieved successfully " +
      "via Flask API."
    );

  } catch (error) {
    $("landResult").textContent =
      "No land data available.";

    handleError(error);
  }
}

// ======================================
// 8. OWNERSHIP TRANSFER
// ======================================

async function requestTransfer() {
  const landId = input("transferId");
  const newOwner = input("newOwner");

  if (
    !landId ||
    !ethers.isAddress(newOwner)
  ) {
    showStatus(
      "Please enter a valid Land ID " +
      "and new owner address.",
      true
    );

    return;
  }

  await sendTransaction(
    (c) =>
      c.requestTransfer(
        landId,
        newOwner
      )
  );
}

// ======================================
// 9. TRANSFER APPROVAL
// ======================================

async function approveTransfer() {
  const landId = input("approveId");

  if (!landId) {
    showStatus(
      "Please enter a Land ID.",
      true
    );

    return;
  }

  await sendTransaction(
    (c) =>
      c.approveTransfer(landId)
  );
}

async function rejectTransfer() {
  const landId = input("approveId");

  if (!landId) {
    showStatus(
      "Please enter a Land ID.",
      true
    );

    return;
  }

  await sendTransaction(
    (c) =>
      c.rejectTransfer(landId)
  );
}

// ======================================
// 10. OWNERSHIP HISTORY VIA FLASK API
// ======================================

async function viewHistory() {
  try {
    const landId = input("historyId");

    if (!landId) {
      throw new Error(
        "Please enter a Land ID."
      );
    }

    showStatus(
      "Loading ownership history " +
      "from Flask API..."
    );

    const data = await fetchApi(
      "/lands/" +
      encodeURIComponent(landId) +
      "/history"
    );

    if (!Array.isArray(data.history)) {
      throw new Error(
        "Invalid ownership history " +
        "response from Flask API."
      );
    }

    const results = data.history.map(
      (record, index) => {
        const timestamp =
          Number(record.timestamp);

        const date =
          Number.isFinite(timestamp)
            ? new Date(
                timestamp * 1000
              ).toLocaleString("en-GB")
            : "Unknown";

        return (
          "Ownership Record #" +
          (index + 1) + "\n" +
          "Owner: " +
          record.owner + "\n" +
          "Recorded At: " +
          date
        );
      }
    );

    $("historyResult").textContent =
      results.join(
        "\n\n--------------------\n\n"
      ) ||
      "No ownership history found.";

    showStatus(
      "Ownership history loaded " +
      "successfully via Flask API."
    );

  } catch (error) {
    $("historyResult").textContent =
      "No history loaded.";

    handleError(error);
  }
}

// ======================================
// 11. BUTTON EVENT LISTENERS
// ======================================

$("connectWallet").addEventListener(
  "click",
  connectWallet
);

$("registerBtn").addEventListener(
  "click",
  registerLand
);

$("searchBtn").addEventListener(
  "click",
  searchLand
);

$("requestBtn").addEventListener(
  "click",
  requestTransfer
);

$("approveBtn").addEventListener(
  "click",
  approveTransfer
);

$("rejectBtn").addEventListener(
  "click",
  rejectTransfer
);

$("historyBtn").addEventListener(
  "click",
  viewHistory
);

// ======================================
// 12. WALLET OR NETWORK CHANGES
// ======================================

function resetConnection() {
  provider = null;
  signer = null;
  contract = null;

  $("walletAddress").textContent =
    "Wallet not connected";

  $("connectionStatus").textContent =
    "Not connected";

  [
    "totalLands",
    "totalApproved",
    "totalPending",
    "currentBlock"
  ].forEach((id) => {
    $(id).textContent = "—";
  });

  $("landResult").textContent =
    "No land selected.";

  $("historyResult").textContent =
    "No history loaded.";

  showStatus(
    "Wallet or network changed. " +
    "Please reconnect."
  );
}

if (window.ethereum) {
  window.ethereum.on(
    "accountsChanged",
    resetConnection
  );

  window.ethereum.on(
    "chainChanged",
    resetConnection
  );
}

// ======================================
// 13. START APPLICATION
// ======================================

openPage("dashboard");
