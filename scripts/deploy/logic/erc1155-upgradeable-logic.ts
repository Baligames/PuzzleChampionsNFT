import { HardhatRuntimeEnvironment } from 'hardhat/types';

const deploy = async ({ getNamedAccounts, deployments, ethers }: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy('ChampionChestNFTLogic', {
    contract: 'ChampionChestNFT',
    from: deployer,
    log: true,
  });
};

deploy.tags = ['ChampionChestNFTLogic'];
deploy.dependencies = ['VerifyContracts'];

export default deploy;
