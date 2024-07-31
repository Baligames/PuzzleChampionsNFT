import { ChampionsNFTUpgradeable__factory } from '../../typechain-types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import TransparentUpgradeableProxy from 'hardhat-deploy/extendedArtifacts/TransparentUpgradeableProxy.json';

const erc721Interface = ChampionsNFTUpgradeable__factory.createInterface();

const deploy = async ({ getNamedAccounts, deployments, network }: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const proxyAdmin = await deployments.get('ProxyAdmin');
  const logicContract = await deployments.get('ChampionsNFTUpgradeableLogic');

  const data = erc721Interface.encodeFunctionData('initialize', ['ChampionsNFT', 'CHAMP_NFT', 'https://nft.axie-champions.com/']);

  await deploy('ChampionsNFTCommonUpgradeableProxy', {
    contract: TransparentUpgradeableProxy,
    from: deployer,
    log: true,
    args: [logicContract.address, proxyAdmin.address, data],
  });
};

deploy.tags = ['ChampionsNFTUpgradeableProxy'];
deploy.dependencies = ['VerifyContracts', 'ProxyAdmin', 'ChampionsNFTUpgradeableLogic'];

export default deploy;
