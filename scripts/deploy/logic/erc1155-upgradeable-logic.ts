import { HardhatRuntimeEnvironment } from 'hardhat/types';

const deploy = async ({ getNamedAccounts, deployments, ethers }: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy('PuzzleChampionsNFTLogic', {
    contract: 'PuzzleChampionsNFT',
    from: deployer,
    log: true,
    gasLimit: 10000000,
  });
};

deploy.tags = ['PuzzleChampionsNFTUpgrade'];
deploy.dependencies = ['VerifyContracts'];

export default deploy;