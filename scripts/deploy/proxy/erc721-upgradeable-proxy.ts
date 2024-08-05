import { PuzzleChampionsNFT__factory } from '../../typechain-types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import TransparentUpgradeableProxy from 'hardhat-deploy/extendedArtifacts/TransparentUpgradeableProxy.json';

const erc721Interface = PuzzleChampionsNFT__factory.createInterface();

const deploy = async ({ getNamedAccounts, deployments, network }: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const logicContract = await deployments.get('PuzzleChampionsNFTLogic');

  const data = erc721Interface.encodeFunctionData('initialize', ['PuzzleChampionsNFT', 'PUZZ_CHAMP', 'https://nft.axie-champions.com/']);

  await deploy('PuzzleChampionsNFT', {  // PuzzleChampionsNFT Proxy
    contract: TransparentUpgradeableProxy,
    from: deployer,
    log: true,
    args: [logicContract.address, deployer ,data],
  });
};

deploy.tags = ['PuzzleChampionsNFT'];
deploy.dependencies = ['VerifyContracts', 'PuzzleChampionsNFTLogic'];

export default deploy;
