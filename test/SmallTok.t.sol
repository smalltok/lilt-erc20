// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {SmallTok} from "../contracts/SmallTok.sol";

contract NonOwner {
    function tryMint(SmallTok token, address account, uint256 amount) external returns (bool) {
        (bool success,) = address(token).call(
            abi.encodeWithSignature("mint(address,uint256)", account, amount)
        );
        return success;
    }
}

contract SmallTokTest {
    function testInitialState() public {
        SmallTok token = new SmallTok(address(this));

        require(token.owner() == address(this), "incorrect owner");
        require(keccak256(bytes(token.name())) == keccak256(bytes("SmallTok")), "incorrect name");
        require(keccak256(bytes(token.symbol())) == keccak256(bytes("SMALLTOK")), "incorrect symbol");
        require(token.decimals() == 18, "incorrect decimals");
        require(token.totalSupply() == 0, "unexpected initial supply");
    }

    function testMintAndBurn() public {
        SmallTok token = new SmallTok(address(this));
        address recipient = address(0x1234);

        token.mint(recipient, 100);
        require(token.balanceOf(recipient) == 100, "incorrect minted balance");
        require(token.totalSupply() == 100, "incorrect supply after mint");

        token.mint(address(this), 50);
        token.burn(20);
        require(token.balanceOf(address(this)) == 30, "incorrect balance after burn");
        require(token.totalSupply() == 130, "incorrect supply after burn");
    }

    function testMintIsOwnerOnly() public {
        SmallTok token = new SmallTok(address(this));
        NonOwner caller = new NonOwner();

        require(!caller.tryMint(token, address(caller), 100), "non-owner minted tokens");
        require(token.totalSupply() == 0, "supply changed after unauthorized mint");
    }
}