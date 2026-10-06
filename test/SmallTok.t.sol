// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {SmallTok} from "../contracts/SmallTok.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract SmallTokV2 is SmallTok {
    function version() external pure returns (uint256) {
        return 2;
    }
}

contract NonOwner {
    function tryMint(SmallTok token, address account, uint256 amount) external returns (bool) {
        (bool success,) = address(token).call(
            abi.encodeWithSignature("mint(address,uint256)", account, amount)
        );
        return success;
    }

    function tryUpgrade(SmallTok token, address implementation) external returns (bool) {
        (bool success,) = address(token).call(
            abi.encodeWithSignature("upgradeToAndCall(address,bytes)", implementation, "")
        );
        return success;
    }
}

contract SmallTokTest {
    function testInitialState() public {
        SmallTok token = _deployToken(address(this));

        require(token.owner() == address(this), "incorrect owner");
        require(keccak256(bytes(token.name())) == keccak256(bytes("SmallTok")), "incorrect name");
        require(keccak256(bytes(token.symbol())) == keccak256(bytes("SMALLTOK")), "incorrect symbol");
        require(token.decimals() == 18, "incorrect decimals");
        require(token.totalSupply() == 0, "unexpected initial supply");
    }

    function testMintAndBurn() public {
        SmallTok token = _deployToken(address(this));
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
        SmallTok token = _deployToken(address(this));
        NonOwner caller = new NonOwner();

        require(!caller.tryMint(token, address(caller), 100), "non-owner minted tokens");
        require(token.totalSupply() == 0, "supply changed after unauthorized mint");
    }

    function testImplementationCannotBeInitialized() public {
        SmallTok implementation = new SmallTok();
        (bool success,) = address(implementation).call(
            abi.encodeCall(SmallTok.initialize, (address(this)))
        );
        require(!success, "implementation was initialized");
    }

    function testOwnerCanUpgradeAndStateIsPreserved() public {
        SmallTok token = _deployToken(address(this));
        token.mint(address(this), 75);

        SmallTokV2 implementation = new SmallTokV2();
        token.upgradeToAndCall(address(implementation), "");

        require(SmallTokV2(address(token)).version() == 2, "implementation not upgraded");
        require(token.owner() == address(this), "owner changed after upgrade");
        require(token.balanceOf(address(this)) == 75, "balance changed after upgrade");
        require(token.totalSupply() == 75, "supply changed after upgrade");
    }

    function testUpgradeIsOwnerOnly() public {
        SmallTok token = _deployToken(address(this));
        SmallTokV2 implementation = new SmallTokV2();
        NonOwner caller = new NonOwner();

        require(!caller.tryUpgrade(token, address(implementation)), "non-owner upgraded token");
        require(token.owner() == address(this), "owner changed after rejected upgrade");
        require(token.totalSupply() == 0, "state changed after rejected upgrade");
    }

    function _deployToken(address initialOwner) private returns (SmallTok) {
        SmallTok implementation = new SmallTok();
        bytes memory initData = abi.encodeCall(SmallTok.initialize, (initialOwner));
        return SmallTok(address(new ERC1967Proxy(address(implementation), initData)));
    }
}