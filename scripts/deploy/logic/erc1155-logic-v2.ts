import { HardhatRuntimeEnvironment } from 'hardhat/types';

const deploy = async ({ getNamedAccounts, deployments, ethers }: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy('ChampionGachaChestNFTv2', {
    contract: 'ChampionGachaChestNFTv2',
    from: deployer,
    log: true,
  });
};

deploy.tags = ['ChampionGachaChestNFTv2'];
deploy.dependencies = ['VerifyContracts'];

export default deploy;
