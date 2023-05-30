// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/core/MentorHub.sol";

contract MentorHubScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address governance = vm.envAddress("GOVERNENCE");
        address emergencyAdmin = vm.envAddress("EMERGENCY_ADMIN");
        address dispatcher = vm.envAddress("DISPATCHER");

        vm.startBroadcast(deployerPrivateKey);

        MentorHub mentorHub = new MentorHub("MentorDAO", "MENTOR", governance, emergencyAdmin, dispatcher);

        vm.stopBroadcast();
    }
}

// forge script script/MentorHub.s.sol:MentorHubScript --rpc-url $RPC_URL --broadcast --verify -vvvv
