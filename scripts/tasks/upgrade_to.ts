import { HardhatRuntimeEnvironment } from 'hardhat/types/runtime';
import { ChampionGachaChestNFT__factory } from "../typechain-types";
const { LOGIC_ADDRESS, PROXY_ADDRESS, UPGRADE_LOGIC } = process.env;

export default async function upgrade_to(params: any, hre: HardhatRuntimeEnvironment): Promise<void> {
  const ethers = hre.ethers;

  const proxyAddress = PROXY_ADDRESS;

  const [deplyer,minter] = await ethers.getSigners();

  //console.log(`Balance for 1st account ${await minter.getAddress()}: ${await minter.getBalance()}`);

  const championGachaChestNFT = ChampionGachaChestNFT__factory.connect(proxyAddress, deplyer) as ChampionGachaChestNFT;

  const tx = await championGachaChestNFT.upgradeTo(UPGRADE_LOGIC);

  // 트랜잭션 대기
  const receipt = await tx.wait();      
  
  console.log(`Successfully Upgrade Logic to ${UPGRADE_LOGIC}`);

}
