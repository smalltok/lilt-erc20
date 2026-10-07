# lilt-erc20

LilTok (LILT) is an ERC-20 token with permit support and owner-authorized UUPS upgrades.

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

This repository contains no deployed LilTok address. `make deploy` creates a new
implementation and proxy; `make upgrade` upgrades the proxy configured in `TOKEN_ADDRESS`.

To mint through the proxy, set `TOKEN_ADDRESS` to the proxy address, then set `MINT_TO`
and `MINT_AMOUNT` in `.env`. The amount is specified in whole tokens; the script
converts it using the token's decimals.

```sh
make mint
```

To deploy the current implementation and upgrade the proxy in `TOKEN_ADDRESS`, run
`make upgrade`. The deployer key must belong to the proxy owner. The command creates
a new implementation and updates the proxy; it does not deploy a new token proxy.
Run `forge test` locally before using it on a network.