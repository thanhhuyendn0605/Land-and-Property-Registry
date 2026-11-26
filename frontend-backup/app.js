
const CONTRACT_ADDRESS =
  "0xc918a5AaD7Ee965dBcCca8f7961A7E8d7c208D25";

const CHAIN_ID = "0x539"; // Ganache 1337

let provider;
let signer;
let contract;
let abi;

const $ = (id) => document.getElementById(id);
const value = (id) => $(id).value.trim();

function showStatus(message) {
  $("status").textContent = message;
}

function showError(error) {
  console.error(error);
  showStatus(
    "Error: " +
    (error.reason || error.shortMessage || error.message)
  );
}

function requireContract() {
  if (!contract) {
    throw new Error("Please connect MetaMask first.");
  }
  return contract;
}

async function connectWallet() {
  try {
    if (!window.ethereum) {
      throw new Error("MetaMask is not installed.");
    }

    if (!window.ethers) {
      throw new Error("Ethers.js could not load.");
    }

    showStatus("Connecting to MetaMask...");

    const chainId = await window.ethereum.request({
      method: "eth_chainId"
    });

    if (chainId.toLowerCase() !== CHAIN_ID) {
      await window.ethereum.request({
        method: "wallet_switchEthereumChain",
        params: [{ chainId: CHAIN_ID }]
      });
    }

    await window.ethereum.request({
      method: "eth_requestAccounts"
    });

    provider = new ethers.BrowserProvider(window.ethereum);
    signer = await provider.getSigner();

    const network = await provider.getNetwork();

    if (network.chainId !== 1337n) {
      throw new Error("Please select Ganache Local.");
    }

    const response = await fetch("./LandRegistry_ABI.json");

    if (!response.ok) {
      throw new Error("Cannot load LandRegistry_ABI.json");
    }

    abi = await response.json();

    const code = await provider.getCode(CONTRACT_ADDRESS);

    if (code === "0x") {
      throw new Error(
        "LandRegistry contract not found on this network."
      );
    }

    contract = new ethers.Contract(
      CONTRACT_ADDRESS,
      abi,
      signer
    );

    const address = await signer.getAddress();

    $("walletAddress").textContent =
      "Connected: " + address;

    showStatus("Connected to Ganache Local successfully!");
  } catch (error) {
    contract = null;
    showError(error);
  }
}

async function sendTransaction(action) {
  try {
    const c = requireContract();

    showStatus("Please confirm the transaction in MetaMask...");

    const tx = await action(c);

    showStatus("Transaction sent. Waiting for confirmation...");

    const receipt = await tx.wait();

    if (!receipt || receipt.status !== 1) {
      throw new Error("Transaction failed.");
    }

    showStatus(
      "Transaction successful! Gas used: " +
      receipt.gasUsed.toString()
    );
  } catch (error) {
    showError(error);
  }
}

async function registerLand() {
  const landId = value("landId");
  const location = value("location");
  const area = value("area");
  const owner = value("owner");

  if (!landId || !location || !area || !owner) {
    showStatus("Please fill in all land information.");
    return;
  }

  if (!/^[1-9]\d*$/.test(area) ||
      !ethers.isAddress(owner)) {
    showStatus("Invalid area or owner address.");
    return;
  }

  await sendTransaction((c) =>
    c.registerLand(landId, location, BigInt(area), owner)
  );
}

async function searchLand() {
  try {
    const c = requireContract();
    const landId = value("searchId");

    if (!landId) {
      throw new Error("Enter a Land ID.");
    }

    const land = await c.getLand(landId);

    $("landResult").textContent =
      "Land ID: " + landId + "\n" +
      "Location: " + land[0] + "\n" +
      "Area: " + land[1].toString() + " m²\n" +
      "Owner: " + land[2];

    showStatus("Land information loaded.");
  } catch (error) {
    showError(error);
  }
}

async function requestTransfer() {
  const landId = value("transferId");
  const newOwner = value("newOwner");

  if (!landId || !ethers.isAddress(newOwner)) {
    showStatus("Invalid Land ID or new owner address.");
    return;
  }

  await sendTransaction((c) =>
    c.requestTransfer(landId, newOwner)
  );
}

async function approveTransfer() {
  const landId = value("approveId");

  if (!landId) {
    showStatus("Enter a Land ID.");
    return;
  }

  await sendTransaction((c) =>
    c.approveTransfer(landId)
  );
}

async function rejectTransfer() {
  const landId = value("approveId");

  if (!landId) {
    showStatus("Enter a Land ID.");
    return;
  }

  await sendTransaction((c) =>
    c.rejectTransfer(landId)
  );
}

async function viewHistory() {
  try {
    const c = requireContract();
    const landId = value("historyId");

    if (!landId) {
      throw new Error("Enter a Land ID.");
    }

    const history = await c.getOwnershipHistory(landId);

    const lines = history.map((record, index) => {
      const date = new Date(
        Number(record[1]) * 1000
      ).toLocaleString("vi-VN");

      return (
        "Record " + (index + 1) + "\n" +
        "Owner: " + record[0] + "\n" +
        "Date: " + date
      );
    });

    $("historyResult").textContent =
      lines.join("\n\n") || "No ownership history.";

    showStatus("Ownership history loaded.");
  } catch (error) {
    showError(error);
  }
}

$("connectWallet").onclick = connectWallet;
$("registerBtn").onclick = registerLand;
$("searchBtn").onclick = searchLand;
$("requestBtn").onclick = requestTransfer;
$("approveBtn").onclick = approveTransfer;
$("rejectBtn").onclick = rejectTransfer;
$("historyBtn").onclick = viewHistory;

if (window.ethereum) {
  window.ethereum.on("accountsChanged", () => {
    contract = null;
    $("walletAddress").textContent = "Wallet not connected";
    showStatus("Account changed. Connect MetaMask again.");
  });

  window.ethereum.on("chainChanged", () => {
    contract = null;
    $("walletAddress").textContent = "Wallet not connected";
    showStatus("Network changed. Connect MetaMask again.");
  });
}
