
 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LandRegistry.sol";

contract UnauthorizedUser {

    function register(LandRegistry registry) external {
        registry.registerLand(
            "LAND003",
            "Da Nang",
            200,
            address(this)
        );
    }

    function transfer(LandRegistry registry) external {
        registry.requestTransfer(
            "LAND002",
            address(0x1234)
        );
    }

    function approve(LandRegistry registry) external {
        registry.approveTransfer("LAND002");
    }
}
