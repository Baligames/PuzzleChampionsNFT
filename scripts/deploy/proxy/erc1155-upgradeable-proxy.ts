import { PuzzleChampionsNFT__factory } from '../../typechain-types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import TransparentUpgradeableProxy from 'hardhat-deploy/extendedArtifacts/TransparentUpgradeableProxy.json';

const ercInterface = PuzzleChampionsNFT__factory.createInterface();

const deploy = async ({ getNamedAccounts, deployments, network }: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const logicContract = await deployments.get('PuzzleChampionsNFTLogic');

  const data = ercInterface.encodeFunctionData('initialize',[deployer,deployer]);

  await deploy('PuzzleChampionsNFT', {  // PuzzleChampionsNFT Proxy
    contract: TransparentUpgradeableProxy,
    from: deployer,
    log: true,
    args: [logicContract.address, deployer ,data],
  });
};

deploy.tags = ['PuzzleChampionsNFT'];
deploy.dependencies = ['VerifyContracts', 'PuzzleChampionsNFTLogic'];

export default deploy;
