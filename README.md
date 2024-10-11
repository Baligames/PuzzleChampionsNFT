# contract-template

## Reference
- forked from : https://github.com/axieinfinity/contract-template/tree/feature/nft-contract-template

## Development

- Use Foundry:

```bash
forge install
forge test
```

- Use Hardhat:

```bash
npm install
npm run test
# or
yarn
yarn test
```

- Pull submodules:

```bash
git submodule update --init --recursive
```

## Deployment

- Saigon testnet:

    ```bash
    yarn deploy --network ronin-testnet
    ```

- Ronin mainnet:

    ```bash
    yarn deploy --network ronin-mainnet
    ```

## Features

- Write / run tests with either Hardhat or Foundry:

```bash
forge test
yarn test
```

- Use Hardhat's task framework

```bash
yarn hardhat example
```

## Compile
```
npx hardhat clean
npx hardhat compile --network ronin-testnet
```

## Upgrade Contract
```
npx hardhat task_upgrade_to --network ronin-testnet
```

## mint Contract
```
npx hardhat task_mint --network ronin-testnet
```