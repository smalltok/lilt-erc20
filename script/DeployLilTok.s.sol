// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {LilTok} from "../contracts/LilTok.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

interface Vm {
    function envAddress(string calldata name) external view returns (address);
    function startBroadcast() external;
    function stopBroadcast() external;
}

contract DeployLilTok {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function run() external returns (LilTok token) {
        address initialOwner = vm.envAddress("INITIAL_OWNER");
        bytes memory initData = abi.encodeCall(LilTok.initialize, (initialOwner));

        vm.startBroadcast();
        LilTok implementation = new LilTok();
        token = LilTok(address(new ERC1967Proxy(address(implementation), initData)));
        vm.stopBroadcast();
    }
}