import { HardhatRuntimeEnvironment } from 'hardhat/types/runtime';
import { PuzzleChampionsNFT__factory } from "../typechain-types";
const { LOGIC_ADDRESS, PROXY_ADDRESS, UPGRADE_LOGIC } = process.env;

export default async function mint(params: any, hre: HardhatRuntimeEnvironment): Promise<void> {
  const ethers = hre.ethers;

  // TODO - deploy 이후 .env 에서 PROXY_ADDRESS 를 바꿔야함.
  const proxyAddress = PROXY_ADDRESS;

  // NFT를 받을 주소 설정
  const recipientAddress = "0x67da6779670edbbf2ec8657eeb9ddaf8b84fddda";

  const [deplyer,minter] = await ethers.getSigners();

  console.log("Using account:", minter.address);

  const manualGasLimit = ethers.BigNumber.from("1000000");

  //console.log(`Balance for 1st account ${await minter.getAddress()}: ${await minter.getBalance()}`);

  const puzzleChampionsNFT = PuzzleChampionsNFT__factory.connect(proxyAddress, minter) as PuzzleChampionsNFT;

  //try {

    // 가스 추정
    console.log("Estimating gas...");
    const estimatedGas = await puzzleChampionsNFT.estimateGas.mintLaunchpad(recipientAddress, 1, "0x");
    console.log("Estimated gas:", estimatedGas.toString())
    const gas_limit_option = {gasLimit: manualGasLimit}

    console.log("Minting NFT...");
    
    // mint 함수 호출
    // const tx = await puzzleChampionsNFT.mintNFT(recipientAddress, gas_limit_option);
    // mintLaunchpad 함수 호출
    const tx = await puzzleChampionsNFT.mintLaunchpad(recipientAddress, 20, "0x", gas_limit_option);
    
    // 트랜잭션 대기
    const receipt = await tx.wait();
    
    // 민팅된 토큰 ID 가져오기
    const mintEvent = receipt.events?.find(event => event.event === 'TransferSingle');
    const tokenId = mintEvent?.args?.id;

    console.log(`Successfully mintLaunchpad NFT with token ID ${tokenId} to ${recipientAddress}`);

    // balance 확인
    const mint_tx = await puzzleChampionsNFT.mintCapsule(recipientAddress, 1001, gas_limit_option);
    const mint_result = await mint_tx.wait();
    console.log(mint_result);

    const chest_balance = await puzzleChampionsNFT.balanceOf(recipientAddress, 1);
    console.log(`Chest balance: ${chest_balance}`);

    const capsule_balance = await puzzleChampionsNFT.balanceOf(recipientAddress, 1001);
    console.log(`Capsule balance: ${capsule_balance}`);

  //} catch (error) {
  //  console.error("Error minting NFT:", error);
  //}

}
