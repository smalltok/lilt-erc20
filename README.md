# smalltok-erc20

SmallTok is an ERC-20 token with permit support and an owner set at deployment.

## Build and test

This project uses Foundry. OpenZeppelin Contracts 5.6.1 is resolved from the existing
`.deps/npm/@openzeppelin/contracts@5.6.1` directory.

```sh
forge build
forge test
```

To deploy, copy `.env.example` to `.env` and set the RPC URL, deployer private key,
and token owner address. The deployer and token owner can be different addresses.
The `.env` file is ignored by Git.

```sh
cp .env.example .env
make deploy
```

To mint, set `TOKEN_ADDRESS`, `MINT_TO`, and `MINT_AMOUNT` in `.env`. The amount is
specified in whole tokens; the script converts it using the token's decimals.

```sh
make mint
```