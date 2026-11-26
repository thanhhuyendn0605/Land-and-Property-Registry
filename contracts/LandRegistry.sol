
 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LandRegistry {
    address public officer;

    struct Land {
        string location;
        uint256 area;
        address owner;
        bool exists;
    }

    struct OwnershipRecord {
        address owner;
        uint256 timestamp;
    }

    struct TransferRequest {
        address newOwner;
        bool pending;
    }

    mapping(string => Land) private lands;
    mapping(string => OwnershipRecord[]) private histories;
    mapping(string => TransferRequest) public transfers;

    event LandRegistered(string landId, address indexed owner);
    event TransferRequested(string landId, address indexed from, address indexed to);
    event TransferApproved(string landId, address indexed oldOwner, address indexed newOwner);
    event TransferRejected(string landId);

    constructor() {
        officer = msg.sender;
    }

    modifier onlyOfficer() {
        require(msg.sender == officer, "Only officer");
        _;
    }

    function registerLand(
        string memory landId,
        string memory location,
        uint256 area,
        address owner
    ) public onlyOfficer {
        require(bytes(landId).length > 0, "Invalid ID");
        require(!lands[landId].exists, "Land exists");
        require(area > 0, "Invalid area");
        require(owner != address(0), "Invalid owner");

        lands[landId] = Land(location, area, owner, true);

        histories[landId].push(
            OwnershipRecord(owner, block.timestamp)
        );

        emit LandRegistered(landId, owner);
    }

    function getLand(string memory landId)
        public view returns (string memory, uint256, address)
    {
        require(lands[landId].exists, "Land not found");

        Land storage land = lands[landId];
        return (land.location, land.area, land.owner);
    }

    function requestTransfer(
        string memory landId,
        address newOwner
    ) public {
        require(lands[landId].exists, "Land not found");
        require(msg.sender == lands[landId].owner, "Not owner");
        require(newOwner != address(0), "Invalid owner");
        require(newOwner != msg.sender, "Same owner");
        require(!transfers[landId].pending, "Transfer pending");

        transfers[landId] = TransferRequest(newOwner, true);

        emit TransferRequested(landId, msg.sender, newOwner);
    }

    function approveTransfer(string memory landId)
        public onlyOfficer
    {
        require(lands[landId].exists, "Land not found");
        require(transfers[landId].pending, "No request");

        address oldOwner = lands[landId].owner;
        address newOwner = transfers[landId].newOwner;

        lands[landId].owner = newOwner;

        histories[landId].push(
            OwnershipRecord(newOwner, block.timestamp)
        );

        delete transfers[landId];

        emit TransferApproved(landId, oldOwner, newOwner);
    }

    function rejectTransfer(string memory landId)
        public onlyOfficer
    {
        require(transfers[landId].pending, "No request");

        delete transfers[landId];

        emit TransferRejected(landId);
    }

    function getOwnershipHistory(string memory landId)
        public view returns (OwnershipRecord[] memory)
    {
        require(lands[landId].exists, "Land not found");
        return histories[landId];
    }
}
