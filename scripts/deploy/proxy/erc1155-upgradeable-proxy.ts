import { PuzzleChampionsNFT__factory } from '../../typechain-types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import TransparentUpgradeableProxy from 'hardhat-deploy/extendedArtifacts/TransparentUpgradeableProxy.json';

const ercInterface = PuzzleChampionsNFT__factory.createInterface();

const deploy = async ({ getNamedAccounts, deployments, network, ethers }: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  const { deployer, minter } = await getNamedAccounts();
  const logicContract = await deployments.get('PuzzleChampionsNFTLogic');

  const data = ercInterface.encodeFunctionData('initialize',["PuzzleChampionsNFT","PUZZLE_CHAMP",minter]);

  await deploy('PuzzleChampionsNFTProxy', {  // PuzzleChampionsNFT Proxy
    contract: TransparentUpgradeableProxy,
    from: deployer,
    log: true,
    args: [logicContract.address, deployer ,data],
    gasPrice: ethers.utils.parseUnits('20', 'gwei')
  });
};

deploy.tags = ['PuzzleChampionsNFT'];
deploy.dependencies = ['VerifyContracts', 'PuzzleChampionsNFTLogic'];

export default deploy;
