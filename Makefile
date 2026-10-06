-include .env
export RPC_URL DEPLOYER_PRIVATE_KEY INITIAL_OWNER TOKEN_ADDRESS MINT_TO MINT_AMOUNT

.PHONY: build test deploy mint upgrade

build:
	forge build

test:
	forge test

deploy:
	@test -n "$$RPC_URL" || (echo "Set RPC_URL in .env" >&2; exit 1)
	@test -n "$$DEPLOYER_PRIVATE_KEY" || (echo "Set DEPLOYER_PRIVATE_KEY in .env" >&2; exit 1)
	@test -n "$$INITIAL_OWNER" || (echo "Set INITIAL_OWNER in .env" >&2; exit 1)
	@forge script script/DeploySmallTok.s.sol:DeploySmallTok \
		--rpc-url "$$RPC_URL" \
		--gas-estimate-multiplier 750 \
		--broadcast \
		--private-key "$$DEPLOYER_PRIVATE_KEY"

mint:
	@test -n "$$RPC_URL" || (echo "Set RPC_URL in .env" >&2; exit 1)
	@test -n "$$DEPLOYER_PRIVATE_KEY" || (echo "Set DEPLOYER_PRIVATE_KEY in .env" >&2; exit 1)
	@test -n "$$TOKEN_ADDRESS" || (echo "Set TOKEN_ADDRESS in .env" >&2; exit 1)
	@test -n "$$MINT_TO" || (echo "Set MINT_TO in .env" >&2; exit 1)
	@test -n "$$MINT_AMOUNT" || (echo "Set MINT_AMOUNT in .env" >&2; exit 1)
	@forge script script/MintSmallTok.s.sol:MintSmallTok \
		--rpc-url "$$RPC_URL" \
		--gas-estimate-multiplier 400 \
		--broadcast \
		--private-key "$$DEPLOYER_PRIVATE_KEY"

upgrade:
	@test -n "$$RPC_URL" || (echo "Set RPC_URL in .env" >&2; exit 1)
	@test -n "$$DEPLOYER_PRIVATE_KEY" || (echo "Set DEPLOYER_PRIVATE_KEY in .env" >&2; exit 1)
	@test -n "$$TOKEN_ADDRESS" || (echo "Set TOKEN_ADDRESS to the proxy address in .env" >&2; exit 1)
	@forge script script/UpgradeSmallTok.s.sol:UpgradeSmallTok \
		--rpc-url "$$RPC_URL" \
		--gas-estimate-multiplier 750 \
		--broadcast \
		--private-key "$$DEPLOYER_PRIVATE_KEY"