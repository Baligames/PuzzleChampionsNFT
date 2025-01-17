import { HardhatRuntimeEnvironment } from 'hardhat/types/runtime';
import { PuzzleChampionsNFT, PuzzleChampionsNFT__factory } from "../typechain-types";
const { LOGIC_ADDRESS, PROXY_ADDRESS, UPGRADE_LOGIC } = process.env;

export default async function mint(params: any, hre: HardhatRuntimeEnvironment): Promise<void> {
  const ethers = hre.ethers;

  // TODO - deploy 이후 .env 에서 PROXY_ADDRESS 를 바꿔야함.
  const proxyAddress = PROXY_ADDRESS;

  // NFT를 받을 주소 설정
  //const recipientAddress = "0x67da6779670edbbf2ec8657eeb9ddaf8b84fddda";
  //const recipientAddress = "0xcf75a0f77da7c15c38f85e3efc072dddf41dceff";
  const recipientAddress = "0xc11e07015d52436f1e3d92c1b79652f7f0be69e9"; // 원익
  //const recipientAddress = "0x82c1e6fbcc42440262cf50ca5979f8460ab1e8ab";
  //const recipientAddress = "0xd7eb9ae71c0bb616a942a61c69661713a7f6798c"; // 경문
  //const recipientAddress = "0x997d4871bf0714484b691de60117eaf3c514a324"; // 종률
  //const recipientAddress = "0x82c1e6fbcc42440262cf50ca5979f8460ab1e8ab"; // 수환
  //const recipientAddress = "0x073614bf61888a563c200a3698192f533cef6a0b"; // 의중
  //const recipientAddress = "0xc5670e22a761ff7dc289e831bd6aeddf0e988fc8"; // 동주
  //const recipientAddress = "0x19e94520df8303a82030cd819c9840138bb51df1"; // 영우
  //const recipientAddress = "0x5060364442ee869cf228ee6c0c4caef3d3306025"; // 호율
  //const recipientAddress = "0x2b250f6b77f0cceecaaffcc5bc4edd797c821c29"; // 휘곤

  const [deplyer,minter] = await ethers.getSigners();

  console.log("Using account:", minter.address);
  console.log("Proxy Address :", proxyAddress);

  const manualGasLimit = ethers.BigNumber.from("10000000");
  const gasPriceInWei = ethers.utils.parseUnits("20", 'gwei');
  console.log(`Gas price in wei: ${gasPriceInWei.toString()}`);

  //console.log(`Balance for 1st account ${await minter.getAddress()}: ${await minter.getBalance()}`);

  const puzzleChampionsNFT = PuzzleChampionsNFT__factory.connect(proxyAddress as string, minter);

  //try {

    // 가스 추정
    console.log("Estimating gas...");
    //const estimatedGas = await puzzleChampionsNFT.estimateGas.mint(recipientAddress, 1, 1,"0x");
    //console.log("Estimated gas:", estimatedGas.toString())
    const gas_limit_option = {gasLimit: manualGasLimit, gasPrice: gasPriceInWei}

    console.log("Minting NFT...");

    //const tx5 = await puzzleChampionsNFT.mintChampionBatch(recipientAddress, [200002, 200003, 200004, 200005, 200006], "0x", gas_limit_option);
    //const receipt5 = await tx5.wait();
    //console.log(receipt5);

    //const tx6 = await puzzleChampionsNFT.fusionChampion(recipientAddress, 10, [200004, 200005], 1000002, "0x", gas_limit_option);
    //const receipt6 = await tx6.wait();
    //console.log(receipt6);

    //const tx7 = await puzzleChampionsNFT.burnChampion(recipientAddress, 1000002, gas_limit_option);
    //const receipt7 = await tx7.wait();
    //console.log(receipt7);

    // mint 함수 호출
    // const tx = await puzzleChampionsNFT.mintNFT(recipientAddress, gas_limit_option);
    // mintLaunchpad 함수 호출
    const tx1 = await puzzleChampionsNFT.mintFusionCore(recipientAddress, 1000, "0x", gas_limit_option);
    //
    //// 트랜잭션 대기
    const receipt1 = await tx1.wait();
    console.log(receipt1);

    const tx2 = await puzzleChampionsNFT.mintCapsule(recipientAddress, 1002, 100, "0x", gas_limit_option);
    //
    //// 트랜잭션 대기
    const receipt2 = await tx2.wait();
    console.log(receipt2);

    const tx3 = await puzzleChampionsNFT.mintCapsule(recipientAddress, 1003, 100, "0x", gas_limit_option);
    //
    //// 트랜잭션 대기
    const receipt3 = await tx3.wait();
    console.log(receipt3);
    //
    //// 민팅된 토큰 ID 가져오기
    //const mintEvent = receipt.events?.find(event => event.event === 'TransferSingle');
    //const tokenId = mintEvent?.args?.id;
//
    //console.log(`Successfully mintLaunchpad NFT with token ID ${tokenId} to ${recipientAddress}`);

    // balance 확인
    //const mint_tx = await puzzleChampionsNFT.mintCapsule(recipientAddress, 1002, 1, "0x", gas_limit_option);
    //const mint_result = await mint_tx.wait();
    //console.log(mint_result);

    const chest_balance = await puzzleChampionsNFT.balanceOf(recipientAddress, 2);
    console.log(`Fusion Core balance: ${chest_balance}`);

    //const capsule_balance = await puzzleChampionsNFT.balanceOf(recipientAddress, 1001);
    //console.log(`Capsule balance: ${capsule_balance}`);

  //} catch (error) {
  //  console.error("Error minting NFT:", error);
  //}

}
