# smalltok-erc20

SmallTok is an ERC-20 token with permit support and owner-authorized UUPS upgrades.

## Build and test

Install the pinned OpenZeppelin dependencies with npm, then build and test with Foundry.

```sh
npm install
forge build
forge test
```

The token implementation uses OpenZeppelin's UUPS pattern behind an ERC-1967 proxy.
Initialization happens atomically during proxy creation, and the implementation
contract itself is locked against initialization. Only the token owner can upgrade it.

To deploy a new proxy, copy `.env.example` to `.env` and set the RPC URL, deployer
private key, and initial owner address. The deployer and owner can be different.
The `.env` file is ignored by Git.

```sh
cp .env.example .env
make deploy
```

The original SmallTok address previously deployed on Sepolia is a non-proxy contract
and cannot be upgraded. A separate UUPS proxy has been deployed at
`0xc1A7CFcebdEF5d2F3EF308752c50c28E0192C514`; its implementation is
`0x6de9924120a691f19fdb246b0cfbedacb90a7da2`. The local `.env` should point
`TOKEN_ADDRESS` to the proxy when using `make mint`. Future calls to `make deploy`
create another implementation and proxy; they do not alter either existing token.

To mint through the proxy, set `TOKEN_ADDRESS` to the proxy address, then set `MINT_TO`
and `MINT_AMOUNT` in `.env`. The amount is specified in whole tokens; the script
converts it using the token's decimals.

```sh
make mint
```