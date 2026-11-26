
 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LandRegistryOptimized.sol";

contract UnauthorizedUserOptimized {

    function register(
        LandRegistryOptimized registry
    ) external {
        registry.registerLand(
            "LAND003",
            "Da Nang",
            200,
            address(this)
        );
    }

    function transfer(
        LandRegistryOptimized registry
    ) external {
        registry.requestTransfer(
            "LAND002",
            address(0x1234)
        );
    }

    function approve(
        LandRegistryOptimized registry
    ) external {
        registry.approveTransfer("LAND002");
    }
}
