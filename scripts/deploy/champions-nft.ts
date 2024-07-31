import { HardhatRuntimeEnvironment } from 'hardhat/types';

const deploy = async ({ getNamedAccounts, deployments }: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  let { deployer } = await getNamedAccounts();

  await deploy('ChampionsNFT', {
    from: deployer,
    log: true,
    args: ['ChampionsNFT', 'CHAMP_NFT', 'https://nft.axie-champions.com/'],
  })
};

deploy.tags = ['ChampionsNFT'];
deploy.dependencies = ['VerifyContracts'];

export default deploy;
