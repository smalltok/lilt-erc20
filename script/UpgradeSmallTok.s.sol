// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {SmallTok} from "../contracts/SmallTok.sol";

interface VmUpgrade {
    function envAddress(string calldata name) external view returns (address);
    function startBroadcast() external;
    function stopBroadcast() external;
}

contract UpgradeSmallTok {
    VmUpgrade private constant vm =
        VmUpgrade(address(uint160(uint256(keccak256("hevm cheat code")))));

    function run() external returns (SmallTok implementation) {
        SmallTok proxy = SmallTok(vm.envAddress("TOKEN_ADDRESS"));

        vm.startBroadcast();
        implementation = new SmallTok();
        proxy.upgradeToAndCall(address(implementation), "");
        vm.stopBroadcast();
    }
}