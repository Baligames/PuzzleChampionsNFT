import { HardhatRuntimeEnvironment } from 'hardhat/types/runtime';
import { PuzzleChampionsNFT__factory } from "../typechain-types";
const { LOGIC_ADDRESS, PROXY_ADDRESS, UPGRADE_LOGIC } = process.env;

export default async function upgrade_to(params: any, hre: HardhatRuntimeEnvironment): Promise<void> {
  const ethers = hre.ethers;

  const proxyAddress = PROXY_ADDRESS;

  const [deplyer,minter] = await ethers.getSigners();

  //console.log(`Balance for 1st account ${await minter.getAddress()}: ${await minter.getBalance()}`);

  const puzzleChampionsNFT = PuzzleChampionsNFT__factory.connect(proxyAddress as string, deplyer);

  const tx = await puzzleChampionsNFT.upgradeTo(UPGRADE_LOGIC as string);

  // 트랜잭션 대기
  const receipt = await tx.wait();      
  
  console.log(receipt);
  console.log(`Successfully Upgrade Logic to ${UPGRADE_LOGIC}`);

}
