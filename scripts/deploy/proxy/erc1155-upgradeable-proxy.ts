import { ChampionChestNFT__factory } from '../../typechain-types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import TransparentUpgradeableProxy from 'hardhat-deploy/extendedArtifacts/TransparentUpgradeableProxy.json';

const ercInterface = ChampionChestNFT__factory.createInterface();

const deploy = async ({ getNamedAccounts, deployments, network }: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  const { deployer, minter } = await getNamedAccounts();
  const logicContract = await deployments.get('ChampionChestNFTLogic');

  const data = ercInterface.encodeFunctionData('initialize',[deployer,minter]);

  await deploy('ChampionChestNFT', {  // ChampionChestNFT Proxy
    contract: TransparentUpgradeableProxy,
    from: deployer,
    log: true,
    args: [logicContract.address, deployer ,data],
  });
};

deploy.tags = ['ChampionChestNFT'];
deploy.dependencies = ['VerifyContracts', 'ChampionChestNFTLogic'];

export default deploy;
