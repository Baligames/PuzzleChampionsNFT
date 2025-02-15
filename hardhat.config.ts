require('dotenv').config();
import '@nomiclabs/hardhat-waffle';
import '@typechain/hardhat';
import '@nomicfoundation/hardhat-foundry';
import 'hardhat-deploy';
import { HardhatUserConfig, task } from 'hardhat/config';
import { NetworkUserConfig } from 'hardhat/types';
import fs from 'fs';
import path from 'path';
import champions from './scripts/tasks/champions';
import mint from './scripts/tasks/mint';
import upgrade_to from './scripts/tasks/upgrade_to';
import set_dev from './scripts/tasks/set_dev';
import burn from './scripts/tasks/burn';
const typechainDir = path.join(__dirname, './scripts/typechain-types');
if (fs.existsSync(typechainDir)) {
  //task('task_champions', 'Champions check balance task').setAction(champions);
  task('task_mint', 'mint test task').setAction(mint);
  task('task_upgrade_to', 'upgrade proxy address task').setAction(upgrade_to);
  task('task_set_dev', 'set dev task').setAction(set_dev);
  task('task_burn', 'burn test task').setAction(burn);
}

const DEFAULT_MNEMONIC = 'title spike pink garlic hamster sorry few damage silver mushroom clever window';

const { TESTNET_PK, TESTNET_URL, MAINNET_PK, MAINNET_URL, DEPLOYER, MINTER } = process.env;

if (!TESTNET_PK) {
  console.warn('TESTNET_PK is unset. Using DEFAULT_MNEMONIC');
} else {
  console.info('TESTNET_PK is set. Using TESTNET_PK');
}

if (!MAINNET_PK) {
  console.warn('MAINNET_PK is unset. Using DEFAULT_MNEMONIC');
}

const testnet: NetworkUserConfig = {
  chainId: 2021,
  url: TESTNET_URL || 'https://saigon-testnet.roninchain.com/rpc',
  accounts: TESTNET_PK ? [TESTNET_PK, MINTER] : { mnemonic: DEFAULT_MNEMONIC },
  blockGasLimit: 100000000,
};

const mainnet: NetworkUserConfig = {
  chainId: 2020,
  url: MAINNET_URL || 'https://api.roninchain.com/rpc',
  accounts: MAINNET_PK ? [MAINNET_PK, MINTER] : { mnemonic: DEFAULT_MNEMONIC },
  blockGasLimit: 100000000,
};

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.19',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  typechain: {
    outDir: './scripts/typechain-types',
  },
  paths: {
    sources: './src',
    cache: './cache/hardhat',
    deploy: ['./scripts/deploy'],
  },
  namedAccounts: {
    deployer: `privatekey://${DEPLOYER}`,
    minter: `privatekey://${MINTER}`,
  },
  networks: {
    hardhat: {
      hardfork: 'istanbul',
      accounts: {
        mnemonic: DEFAULT_MNEMONIC,
      },
    },
    'ronin-testnet': testnet,
    'ronin-mainnet': mainnet,
  },
};

export default config;
