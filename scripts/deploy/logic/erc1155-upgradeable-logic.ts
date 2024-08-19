import { HardhatRuntimeEnvironment } from 'hardhat/types';

const deploy = async ({ getNamedAccounts, deployments, ethers }: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy('ChampionGachaChestNFTLogic', {
    contract: 'ChampionGachaChestNFT',
    from: deployer,
    log: true,
  });
};

deploy.tags = ['ChampionGachaChestNFTLogic'];
deploy.dependencies = ['VerifyContracts'];

export default deploy;
