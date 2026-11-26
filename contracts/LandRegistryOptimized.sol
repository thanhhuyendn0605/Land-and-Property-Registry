
 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LandRegistryOptimized {
    error OnlyOfficer();
error InvalidID();
error LandExists();
error InvalidArea();
error InvalidOwner();
error LandNotFound();
error NotOwner();
error SameOwner();
error TransferPending();
error NoRequest();

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
        if (msg.sender != officer) revert OnlyOfficer();
        _;
    }

    function registerLand(
        string memory landId,
        string memory location,
        uint256 area,
        address owner
    ) public onlyOfficer {
        
if (bytes(landId).length == 0) revert InvalidID();
if (lands[landId].exists) revert LandExists();
if (area == 0) revert InvalidArea();
if (owner == address(0)) revert InvalidOwner();

        
        
        

        lands[landId] = Land(location, area, owner, true);

        histories[landId].push(
            OwnershipRecord(owner, block.timestamp)
        );

        emit LandRegistered(landId, owner);
    }

    function getLand(string memory landId)
        public view returns (string memory, uint256, address)
    {
        if (!lands[landId].exists) revert LandNotFound();

        Land storage land = lands[landId];
        return (land.location, land.area, land.owner);
    }

    function requestTransfer(
        string memory landId,
        address newOwner
    ) public {
        
if (!lands[landId].exists) revert LandNotFound();
if (msg.sender != lands[landId].owner) revert NotOwner();
if (newOwner == address(0)) revert InvalidOwner();
if (newOwner == msg.sender) revert SameOwner();
if (transfers[landId].pending) revert TransferPending();


        transfers[landId] = TransferRequest(newOwner, true);

        emit TransferRequested(landId, msg.sender, newOwner);
    }

    function approveTransfer(string memory landId)
        public onlyOfficer
    {
       
if (!lands[landId].exists) revert LandNotFound();
if (!transfers[landId].pending) revert NoRequest();


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
        
if (!transfers[landId].pending) revert NoRequest();


        delete transfers[landId];

        emit TransferRejected(landId);
    }

    function getOwnershipHistory(string memory landId)
        public view returns (OwnershipRecord[] memory)
    {
       if (!lands[landId].exists) revert LandNotFound();
        return histories[landId];
    }
}
