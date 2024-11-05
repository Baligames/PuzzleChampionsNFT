import { HardhatRuntimeEnvironment } from 'hardhat/types';

const deploy = async ({ getNamedAccounts, deployments, ethers }: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy('PuzzleChampionsNFTLogic', {
    contract: 'PuzzleChampionsNFT',
    from: deployer,
    log: true,
    gasPrice: ethers.utils.parseUnits('100', 'gwei'),
  });
};

deploy.tags = ['PuzzleChampionsNFT'];
deploy.dependencies = ['VerifyContracts'];

export default deploy;
