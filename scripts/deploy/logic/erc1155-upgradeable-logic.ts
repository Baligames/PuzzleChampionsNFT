import { HardhatRuntimeEnvironment } from 'hardhat/types';

const deploy = async ({ getNamedAccounts, deployments, ethers }: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy('PuzzleChampionsNFTLogic', {
    contract: 'PuzzleChampionsNFT',
    from: deployer,
    log: true,
    gasPrice: ethers.utils.parseUnits('20', 'gwei'),
  });
};

deploy.tags = ['PuzzleChampionsNFTUpgrade'];
deploy.dependencies = ['VerifyContracts'];

export default deploy;