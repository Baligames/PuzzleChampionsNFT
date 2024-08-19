import { ChampionGachaChestNFT__factory } from '../../typechain-types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import TransparentUpgradeableProxy from 'hardhat-deploy/extendedArtifacts/TransparentUpgradeableProxy.json';

const ercInterface = ChampionGachaChestNFT__factory.createInterface();

const deploy = async ({ getNamedAccounts, deployments, network }: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  const { deployer, minter } = await getNamedAccounts();
  const logicContract = await deployments.get('ChampionGachaChestNFTLogic');

  const data = ercInterface.encodeFunctionData('initialize',[deployer,minter]);

  await deploy('ChampionGachaChestNFT', {  // ChampionGachaChestNFT Proxy
    contract: TransparentUpgradeableProxy,
    from: deployer,
    log: true,
    args: [logicContract.address, deployer ,data],
  });
};

deploy.tags = ['ChampionGachaChestNFT'];
deploy.dependencies = ['VerifyContracts', 'ChampionGachaChestNFTLogic'];

export default deploy;
