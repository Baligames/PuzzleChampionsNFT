import { HardhatRuntimeEnvironment } from 'hardhat/types/runtime';
import { ChampionGachaChestNFT__factory } from "../typechain-types";
const { LOGIC_ADDRESS, PROXY_ADDRESS, UPGRADE_LOGIC } = process.env;

export default async function mint(params: any, hre: HardhatRuntimeEnvironment): Promise<void> {
  const ethers = hre.ethers;

  const proxyAddress = PROXY_ADDRESS;

  // NFT를 받을 주소 설정
  const recipientAddress = "0x67da6779670edbbf2ec8657eeb9ddaf8b84fddda";

  const [deplyer,minter] = await ethers.getSigners();

  console.log("Using account:", minter.address);

  const manualGasLimit = ethers.BigNumber.from("1000000");

  //console.log(`Balance for 1st account ${await minter.getAddress()}: ${await minter.getBalance()}`);

  const championGachaChestNFT = ChampionGachaChestNFT__factory.connect(proxyAddress, minter) as ChampionGachaChestNFT;

  try {

    // 가스 추정
    //console.log("Estimating gas...");
    //const estimatedGas = await championGachaChestNFT.estimateGas.mintLaunchpad(recipientAddress, 1, "0x");
    //console.log("Estimated gas:", estimatedGas.toString())

    console.log("Minting NFT...");
    
    // mint 함수 호출
    // const tx = await championGachaChestNFT.mintNFT(recipientAddress, {gasLimit: manualGasLimit});
    // mintLaunchpad 함수 호출
    const tx = await championGachaChestNFT.mintLaunchpad(recipientAddress, 1, "0x", {gasLimit: manualGasLimit});
    
    // 트랜잭션 대기
    const receipt = await tx.wait();
    
    // 민팅된 토큰 ID 가져오기
    const mintEvent = receipt.events?.find(event => event.event === 'TransferSingle');
    const tokenId = mintEvent?.args?.id;

    console.log(`Successfully mintLaunchpad NFT with token ID ${tokenId} to ${recipientAddress}`);

    // 토큰 URI 확인
    const tokenURI = await championGachaChestNFT.uri(tokenId);
    console.log(`Token URI: ${tokenURI}`);

  } catch (error) {
    console.error("Error minting NFT:", error);
  }

}
