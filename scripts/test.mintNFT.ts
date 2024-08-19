import { ethers, getNamedAccounts } from "hardhat";

import { ChampionChestNFT__factory } from "./typechain-types";

/*
deploying "ChampionChestNFTLogic" (tx: 0xe4c6475413062648f409f123080799252c43451baba026a221f32951a7ecab2b)...: deployed at 0x37191809ebB7f7d4208Ec3507844493CAc7B8714 with 2850823 gas
deploying "ChampionChestNFT" (tx: 0x875fb913bfcdfa43162be31c59e4c1db2917e46e99b99f3531abeec39cafb4b2)...: deployed at 0x5D9Da2D5108Ca8eEf38D50AAcc5878F6Fb1ADc3A with 938115 gas
verifying ChampionChestNFT (0x5D9Da2D5108Ca8eEf38D50AAcc5878F6Fb1ADc3A on chain 2021) ...
 => contract ChampionChestNFT is now verified
verifying ChampionChestNFTLogic (0x37191809ebB7f7d4208Ec3507844493CAc7B8714 on chain 2021) ...
 => contract ChampionChestNFTLogic is now verified
already verified: PuzzleChampionsNFT (0x594Ba40c719B7F49C2B5b71a4B14Cc7053c36730), skipping.
already verified: PuzzleChampionsNFTLogic (0x7A43FcB12d67007160ADeF4ffCDD51A5C3825534), skipping. */


async function main() {
    // 프록시 컨트랙트 주소 설정 (ChampionChestNFT 프록시 주소)
    const proxyAddress = "0x5D9Da2D5108Ca8eEf38D50AAcc5878F6Fb1ADc3A";
    
    // NFT를 받을 주소 설정
    const recipientAddress = "0x67da6779670edbbf2ec8657eeb9ddaf8b84fddda";
  
    // Hardhat의 ethers 인스턴스 가져오기
    const [deployer,minter] = await ethers.getSigners();

    console.log("Using account:", minter.address);

    const manualGasLimit = ethers.BigNumber.from("1000000");
    
    //const MINTER_ROLE = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("MINTER_ROLE"));

    // deployer 는 못하고 minter 권한 있는 계정만 가능. 민터 권한 발급
    //const tx_grant = await ChampionChestNFT__factory.connect(proxyAddress, deployer).grantRole(MINTER_ROLE, minter.address);
    //const tx_receipt = await tx_grant.wait()
    //console.log("MINTER_ROLE granted to", tx_receipt);
  
    // ChampionChestNFT 컨트랙트 인스턴스 생성
    const championChestNFT = ChampionChestNFT__factory.connect(proxyAddress, minter) as ChampionChestNFT;    
  
    try {

      // 가스 추정
      //console.log("Estimating gas...");
      //const estimatedGas = await championChestNFT.estimateGas.mintLaunchpad(recipientAddress, 1, "0x");
      //console.log("Estimated gas:", estimatedGas.toString())

      console.log("Minting NFT...");
      
      // mintLaunchpad 함수 호출
      const tx = await championChestNFT.mintNFT(recipientAddress, {gasLimit: manualGasLimit});
      
      // 트랜잭션 대기
      const receipt = await tx.wait();
      
      // 민팅된 토큰 ID 가져오기
      const mintEvent = receipt.events?.find(event => event.event === 'TransferSingle');
      const tokenId = mintEvent?.args?.id;
  
      console.log(`Successfully minted NFT with token ID ${tokenId} to ${recipientAddress}`);
  
      // 토큰 URI 확인
      const tokenURI = await championChestNFT.uri(tokenId);
      console.log(`Token URI: ${tokenURI}`);
  
    } catch (error) {
      console.error("Error minting NFT:", error);
    }
  }
  
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });