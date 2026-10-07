// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {LilTok} from "../contracts/LilTok.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract LilTokV2 is LilTok {
    function version() external pure override returns (uint256) {
        return 3;
    }
}

contract NonOwner {
    function tryMint(LilTok token, address account, uint256 amount) external returns (bool) {
        (bool success,) = address(token).call(
            abi.encodeWithSignature("mint(address,uint256)", account, amount)
        );
        return success;
    }

    function tryUpgrade(LilTok token, address implementation) external returns (bool) {
        (bool success,) = address(token).call(
            abi.encodeWithSignature("upgradeToAndCall(address,bytes)", implementation, "")
        );
        return success;
    }
}

contract LilTokTest {
    function testInitialState() public {
        LilTok token = _deployToken(address(this));

        require(token.owner() == address(this), "incorrect owner");
        require(keccak256(bytes(token.name())) == keccak256(bytes("LilTok")), "incorrect name");
        require(keccak256(bytes(token.symbol())) == keccak256(bytes("LILT")), "incorrect symbol");
        require(token.decimals() == 18, "incorrect decimals");
        require(token.totalSupply() == 0, "unexpected initial supply");
        require(token.version() == 2, "incorrect version");
    }

    function testMintAndBurn() public {
        LilTok token = _deployToken(address(this));
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
        LilTok token = _deployToken(address(this));
        NonOwner caller = new NonOwner();

        require(!caller.tryMint(token, address(caller), 100), "non-owner minted tokens");
        require(token.totalSupply() == 0, "supply changed after unauthorized mint");
    }

    function testImplementationCannotBeInitialized() public {
        LilTok implementation = new LilTok();
        (bool success,) = address(implementation).call(
            abi.encodeCall(LilTok.initialize, (address(this)))
        );
        require(!success, "implementation was initialized");
    }

    function testOwnerCanUpgradeAndStateIsPreserved() public {
        LilTok token = _deployToken(address(this));
        token.mint(address(this), 75);
        require(token.version() == 2, "incorrect starting version");

        LilTokV2 implementation = new LilTokV2();
        token.upgradeToAndCall(address(implementation), "");

        require(LilTokV2(address(token)).version() == 3, "implementation not upgraded");
        require(token.owner() == address(this), "owner changed after upgrade");
        require(token.balanceOf(address(this)) == 75, "balance changed after upgrade");
        require(token.totalSupply() == 75, "supply changed after upgrade");
    }

    function testUpgradeIsOwnerOnly() public {
        LilTok token = _deployToken(address(this));
        LilTokV2 implementation = new LilTokV2();
        NonOwner caller = new NonOwner();

        require(!caller.tryUpgrade(token, address(implementation)), "non-owner upgraded token");
        require(token.owner() == address(this), "owner changed after rejected upgrade");
        require(token.totalSupply() == 0, "state changed after rejected upgrade");
    }

    function _deployToken(address initialOwner) private returns (LilTok) {
        LilTok implementation = new LilTok();
        bytes memory initData = abi.encodeCall(LilTok.initialize, (initialOwner));
        return LilTok(address(new ERC1967Proxy(address(implementation), initData)));
    }
}