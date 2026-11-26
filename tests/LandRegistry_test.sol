
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "remix_tests.sol";
import "../contracts/LandRegistry.sol";
import "../contracts/UnauthorizedUser.sol";

contract LandRegistryTest {

    // =====================================
    // TEST 1: DUPLICATE REGISTRATION
    // =====================================

    function testDuplicateLand() public {
        LandRegistry registry = new LandRegistry();

        registry.registerLand(
            "LAND002",
            "Hoi An",
            200,
            address(this)
        );

        bool reverted = false;

        try registry.registerLand(
            "LAND002",
            "Da Nang",
            300,
            address(this)
        ) {
            reverted = false;
        } catch {
            reverted = true;
        }

        Assert.ok(
            reverted,
            "Duplicate land must fail"
        );
    }

    // =====================================
    // TEST 2: UNAUTHORIZED REGISTRATION
    // =====================================

    function testUnauthorizedRegistration() public {
        LandRegistry registry = new LandRegistry();
        UnauthorizedUser user = new UnauthorizedUser();

        bool reverted = false;

        try user.register(registry) {
            reverted = false;
        } catch {
            reverted = true;
        }

        Assert.ok(
            reverted,
            "Only officer can register"
        );
    }

    // =====================================
    // TEST 3: UNAUTHORIZED TRANSFER
    // =====================================

    function testUnauthorizedTransfer() public {
        LandRegistry registry = new LandRegistry();
        UnauthorizedUser user = new UnauthorizedUser();

        registry.registerLand(
            "LAND002",
            "Hoi An",
            200,
            address(this)
        );

        bool reverted = false;

        try user.transfer(registry) {
            reverted = false;
        } catch {
            reverted = true;
        }

        Assert.ok(
            reverted,
            "Only owner can transfer"
        );
    }

    // =====================================
    // TEST 4: SUCCESSFUL OWNERSHIP TRANSFER
    // =====================================

    function testSuccessfulTransfer() public {
        LandRegistry registry = new LandRegistry();

        address newOwner = address(0x1234);

        registry.registerLand(
            "LAND002",
            "Hoi An",
            200,
            address(this)
        );

        registry.requestTransfer(
            "LAND002",
            newOwner
        );

        registry.approveTransfer("LAND002");

        (
            string memory location,
            uint256 area,
            address currentOwner
        ) = registry.getLand("LAND002");

        Assert.ok(
            currentOwner == newOwner,
            "Owner must be updated"
        );

        Assert.ok(
            area == 200,
            "Land area must remain unchanged"
        );

        Assert.ok(
            keccak256(bytes(location)) ==
            keccak256(bytes("Hoi An")),
            "Land location must remain unchanged"
        );

        (, bool pending) = registry.transfers("LAND002");

        Assert.ok(
            !pending,
            "Approved request must be cleared"
        );
    }

    // =====================================
    // TEST 5: UNAUTHORIZED APPROVAL
    // =====================================

    function testUnauthorizedApproval() public {
        LandRegistry registry = new LandRegistry();
        UnauthorizedUser user = new UnauthorizedUser();

        registry.registerLand(
            "LAND002",
            "Hoi An",
            200,
            address(this)
        );

        registry.requestTransfer(
            "LAND002",
            address(0x1234)
        );

        bool reverted = false;

        try user.approve(registry) {
            reverted = false;
        } catch {
            reverted = true;
        }

        Assert.ok(
            reverted,
            "Only officer can approve"
        );

        (, bool pending) = registry.transfers("LAND002");

        Assert.ok(
            pending,
            "Rejected approval must not clear request"
        );
    }

    // =====================================
    // TEST 6: REJECT TRANSFER REQUEST
    // =====================================

    function testRejectTransfer() public {
        LandRegistry registry = new LandRegistry();

        registry.registerLand(
            "LAND002",
            "Hoi An",
            200,
            address(this)
        );

        registry.requestTransfer(
            "LAND002",
            address(0x1234)
        );

        registry.rejectTransfer("LAND002");

        (, bool pending) = registry.transfers("LAND002");

        Assert.ok(
            !pending,
            "Rejected request must be cleared"
        );

        (
            ,
            ,
            address currentOwner
        ) = registry.getLand("LAND002");

        Assert.ok(
            currentOwner == address(this),
            "Owner must not change after rejection"
        );
    }

    // =====================================
    // TEST 7: OWNERSHIP HISTORY
    // =====================================

    function testOwnershipHistory() public {
        LandRegistry registry = new LandRegistry();

        address originalOwner = address(this);
        address newOwner = address(0x1234);

        registry.registerLand(
            "LAND002",
            "Hoi An",
            200,
            originalOwner
        );

        registry.requestTransfer(
            "LAND002",
            newOwner
        );

        registry.approveTransfer("LAND002");

        LandRegistry.OwnershipRecord[] memory records =
            registry.getOwnershipHistory("LAND002");

        Assert.equal(
            records.length,
            uint256(2),
            "History must contain two records"
        );

        Assert.ok(
            records[0].owner == originalOwner,
            "First record must contain original owner"
        );

        Assert.ok(
            records[1].owner == newOwner,
            "Second record must contain new owner"
        );

        Assert.ok(
            records[1].timestamp >= records[0].timestamp,
            "History timestamps must be ordered"
        );
    }

    // =====================================
    // TEST 8: INVALID REGISTRATION INPUT
    // =====================================

    function testInvalidInput() public {
        LandRegistry registry = new LandRegistry();

        bool invalidIdRejected = false;
        bool invalidAreaRejected = false;
        bool invalidOwnerRejected = false;

        // Empty Land ID
        try registry.registerLand(
            "",
            "Da Nang",
            200,
            address(this)
        ) {
            invalidIdRejected = false;
        } catch {
            invalidIdRejected = true;
        }

        // Area must be greater than zero
        try registry.registerLand(
            "LAND003",
            "Da Nang",
            0,
            address(this)
        ) {
            invalidAreaRejected = false;
        } catch {
            invalidAreaRejected = true;
        }

        // Owner cannot be zero address
        try registry.registerLand(
            "LAND004",
            "Da Nang",
            200,
            address(0)
        ) {
            invalidOwnerRejected = false;
        } catch {
            invalidOwnerRejected = true;
        }

        Assert.ok(
            invalidIdRejected,
            "Empty Land ID must fail"
        );

        Assert.ok(
            invalidAreaRejected,
            "Zero area must fail"
        );

        Assert.ok(
            invalidOwnerRejected,
            "Zero owner address must fail"
        );
    }
}
