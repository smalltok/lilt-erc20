// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {SmallTok} from "../contracts/SmallTok.sol";

interface VmMint {
    function envAddress(string calldata name) external view returns (address);
    function envUint(string calldata name) external view returns (uint256);
    function startBroadcast() external;
    function stopBroadcast() external;
}

contract MintSmallTok {
    VmMint private constant vm =
        VmMint(address(uint160(uint256(keccak256("hevm cheat code")))));

    function run() external {
        SmallTok token = SmallTok(vm.envAddress("TOKEN_ADDRESS"));
        address recipient = vm.envAddress("MINT_TO");
        uint256 amount = vm.envUint("MINT_AMOUNT") * 10 ** uint256(token.decimals());

        vm.startBroadcast();
        token.mint(recipient, amount);
        vm.stopBroadcast();
    }
}