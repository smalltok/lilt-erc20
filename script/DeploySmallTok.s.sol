// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {SmallTok} from "../contracts/SmallTok.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

interface Vm {
    function envAddress(string calldata name) external view returns (address);
    function startBroadcast() external;
    function stopBroadcast() external;
}

contract DeploySmallTok {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function run() external returns (SmallTok token) {
        address initialOwner = vm.envAddress("INITIAL_OWNER");
        bytes memory initData = abi.encodeCall(SmallTok.initialize, (initialOwner));

        vm.startBroadcast();
        SmallTok implementation = new SmallTok();
        token = SmallTok(address(new ERC1967Proxy(address(implementation), initData)));
        vm.stopBroadcast();
    }
}