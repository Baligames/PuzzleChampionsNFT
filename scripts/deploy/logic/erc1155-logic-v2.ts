import { HardhatRuntimeEnvironment } from 'hardhat/types';

const deploy = async ({ getNamedAccounts, deployments, ethers }: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy('PuzzleChampionsNFT', {
    contract: 'PuzzleChampionsNFT',
    from: deployer,
    log: true,
  });
};

deploy.tags = ['PuzzleChampionsNFT'];
deploy.dependencies = ['VerifyContracts'];

export default deploy;
