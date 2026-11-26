"""Flask API for the Land & Property Registry Ganache demo.

Run from the project root:
    python backend/app.py
"""

import json
from pathlib import Path

from flask import Flask, jsonify
from flask_cors import CORS
from web3 import Web3
from web3.exceptions import ContractLogicError

app = Flask(__name__)
CORS(app)


CONFIG_PATH = Path(__file__).resolve().parent.parent / "config.json"

with CONFIG_PATH.open("r", encoding="utf-8") as file:
    config = json.load(file)

RPC_URL = config["rpcUrl"]
CONTRACT_ADDRESS = config["contractAddress"]
EXPECTED_CHAIN_ID = int(config["chainId"])


ABI_PATH = Path(__file__).resolve().parent.parent / "frontend" / "LandRegistry_ABI.json"


w3 = Web3(Web3.HTTPProvider(RPC_URL, request_kwargs={"timeout": 10}))


def load_contract():
    """Load ABI and validate the contract on the active Ganache chain."""
    if not w3.is_connected():
        raise ConnectionError("Cannot connect to Ganache")

    if not ABI_PATH.is_file():
        raise FileNotFoundError(f"ABI file not found: {ABI_PATH}")

    with ABI_PATH.open("r", encoding="utf-8") as file:
        abi = json.load(file)

    if not isinstance(abi, list):
        raise ValueError("LandRegistry_ABI.json must contain a JSON array")

    address = Web3.to_checksum_address(CONTRACT_ADDRESS)
    if not w3.eth.get_code(address):
        raise ValueError("Contract not found on the connected Ganache network")

    return w3.eth.contract(address=address, abi=abi)


@app.route("/api/status", methods=["GET"])
def get_status():
    try:
        if not w3.is_connected():
            return jsonify({
                "status": "disconnected",
                "message": "Cannot connect to Ganache",
            }), 503

        return jsonify({
            "status": "connected",
            "network": "Ganache Local",
            "chainId": w3.eth.chain_id,
            "latestBlock": w3.eth.block_number,
        })
    except Exception as exc:
        return jsonify({"status": "error", "message": str(exc)}), 503


@app.route("/api/lands/<land_id>", methods=["GET"])
def get_land(land_id):
    try:
        contract = load_contract()
        location, area, owner = contract.functions.getLand(land_id).call()
        return jsonify({
            "landId": land_id,
            "location": location,
            "area": area,
            "owner": owner,
        })
    except ContractLogicError:
        return jsonify({"error": "Land not found", "landId": land_id}), 404
    except (ConnectionError, FileNotFoundError, ValueError, json.JSONDecodeError) as exc:
        return jsonify({"error": str(exc)}), 503
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500


@app.route("/api/lands/<land_id>/history", methods=["GET"])
def get_land_history(land_id):
    try:
        contract = load_contract()

        records = contract.functions.getOwnershipHistory(
            land_id
        ).call()

        history = [
            {
                "owner": record[0],
                "timestamp": record[1]
            }
            for record in records
        ]

        return jsonify({
            "landId": land_id,
            "totalRecords": len(history),
            "history": history
        })

    except ContractLogicError:
        return jsonify({
            "error": "Land not found",
            "landId": land_id
        }), 404

    except Exception as exc:
        return jsonify({
            "error": str(exc)
        }), 500

@app.route("/api/config", methods=["GET"])
def get_config():
    return jsonify({
        "contractAddress": CONTRACT_ADDRESS,
        "chainId": EXPECTED_CHAIN_ID
    })

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=True)

