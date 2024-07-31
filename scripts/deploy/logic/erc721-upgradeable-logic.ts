import { HardhatRuntimeEnvironment } from 'hardhat/types';

const deploy = async ({ getNamedAccounts, deployments, ethers }: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy('ChampionsNFTUpgradeableLogic', {
    contract: 'ChampionsNFTUpgradeable',
    from: deployer,
    log: true,
  });
};

deploy.tags = ['ChampionsNFTUpgradeableLogic'];
deploy.dependencies = ['VerifyContracts'];

export default deploy;
