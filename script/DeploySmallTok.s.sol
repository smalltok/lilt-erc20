// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {SmallTok} from "../contracts/SmallTok.sol";

interface Vm {
    function envAddress(string calldata name) external view returns (address);
    function startBroadcast() external;
    function stopBroadcast() external;
}

contract DeploySmallTok {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function run() external returns (SmallTok token) {
        address initialOwner = vm.envAddress("INITIAL_OWNER");

        vm.startBroadcast();
        token = new SmallTok(initialOwner);
        vm.stopBroadcast();
    }
}