
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "remix_tests.sol";
import "../contracts/LandRegistryOptimized.sol";
import "../contracts/UnauthorizedUserOptimized.sol";

contract LandRegistryOptimizedTest {

    // TEST 1: Duplicate land registration
    function testDuplicateLand() public {
        LandRegistryOptimized registry =
            new LandRegistryOptimized();

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

        Assert.ok(reverted, "Duplicate land must fail");
    }

    // TEST 2: Unauthorized registration
    function testUnauthorizedRegistration() public {
        LandRegistryOptimized registry =
            new LandRegistryOptimized();

        UnauthorizedUserOptimized user =
            new UnauthorizedUserOptimized();

        bool reverted = false;

        try user.register(registry) {
            reverted = false;
        } catch {
            reverted = true;
        }

        Assert.ok(reverted, "Only officer can register");
    }

    // TEST 3: Unauthorized ownership transfer
    function testUnauthorizedTransfer() public {
        LandRegistryOptimized registry =
            new LandRegistryOptimized();

        UnauthorizedUserOptimized user =
            new UnauthorizedUserOptimized();

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

        Assert.ok(reverted, "Only owner can transfer");
    }

    // TEST 4: Successful ownership transfer
    function testSuccessfulTransfer() public {
        LandRegistryOptimized registry =
            new LandRegistryOptimized();

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

    // TEST 5: Unauthorized transfer approval
    function testUnauthorizedApproval() public {
        LandRegistryOptimized registry =
            new LandRegistryOptimized();

        UnauthorizedUserOptimized user =
            new UnauthorizedUserOptimized();

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
            "Unauthorized approval must not clear request"
        );
    }

    // TEST 6: Reject transfer request
    function testRejectTransfer() public {
        LandRegistryOptimized registry =
            new LandRegistryOptimized();

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

        (,, address currentOwner) =
            registry.getLand("LAND002");

        Assert.ok(
            currentOwner == address(this),
            "Owner must not change after rejection"
        );
    }

    // TEST 7: Ownership history
    function testOwnershipHistory() public {
        LandRegistryOptimized registry =
            new LandRegistryOptimized();

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

        LandRegistryOptimized.OwnershipRecord[] memory records =
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

    // TEST 8: Invalid registration input
    function testInvalidInput() public {
        LandRegistryOptimized registry =
            new LandRegistryOptimized();

        bool invalidIdRejected = false;
        bool invalidAreaRejected = false;
        bool invalidOwnerRejected = false;

        // Empty land ID
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

        // Zero land area
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

        // Zero owner address
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
            "Empty land ID must fail"
        );

        Assert.ok(
            invalidAreaRejected,
            "Zero land area must fail"
        );

        Assert.ok(
            invalidOwnerRejected,
            "Zero owner address must fail"
        );
    }
}
