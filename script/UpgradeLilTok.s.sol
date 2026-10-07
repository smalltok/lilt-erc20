// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {LilTok} from "../contracts/LilTok.sol";

interface VmUpgrade {
    function envAddress(string calldata name) external view returns (address);
    function startBroadcast() external;
    function stopBroadcast() external;
}

contract UpgradeLilTok {
    VmUpgrade private constant vm =
        VmUpgrade(address(uint160(uint256(keccak256("hevm cheat code")))));

    function run() external returns (LilTok implementation) {
        LilTok proxy = LilTok(vm.envAddress("TOKEN_ADDRESS"));

        vm.startBroadcast();
        implementation = new LilTok();
        proxy.upgradeToAndCall(address(implementation), "");
        vm.stopBroadcast();
    }
}