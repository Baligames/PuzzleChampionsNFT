require('dotenv').config();
import { ethers, getNamedAccounts } from "hardhat";
import { ChampionGachaChestNFT__factory } from "./typechain-types";

const { LOGIC_ADDRESS, PROXY_ADDRESS } = process.env;

async function main() {
    // 프록시 컨트랙트 주소 설정 (ChampionGachaChestNFT 프록시 주소)
    const proxyAddress = PROXY_ADDRESS;
    
    // NFT를 받을 주소 설정
    const recipientAddress = "0x67da6779670edbbf2ec8657eeb9ddaf8b84fddda";
  
    // Hardhat의 ethers 인스턴스 가져오기
    const [deployer,minter] = await ethers.getSigners();

    console.log("Using account:", minter.address);

    const manualGasLimit = ethers.BigNumber.from("1000000");
    
    //const MINTER_ROLE = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("MINTER_ROLE"));

    // deployer 는 못하고 minter 권한 있는 계정만 가능. 민터 권한 발급
    //const tx_grant = await ChampionGachaChestNFT__factory.connect(proxyAddress, deployer).grantRole(MINTER_ROLE, minter.address);
    //const tx_receipt = await tx_grant.wait()
    //console.log("MINTER_ROLE granted to", tx_receipt);
  
    // ChampionGachaChestNFT 컨트랙트 인스턴스 생성
    const championGachaChestNFT = ChampionGachaChestNFT__factory.connect(proxyAddress, minter) as ChampionGachaChestNFT;    
  
    try {

      // 가스 추정
      //console.log("Estimating gas...");
      //const estimatedGas = await championGachaChestNFT.estimateGas.mintLaunchpad(recipientAddress, 1, "0x");
      //console.log("Estimated gas:", estimatedGas.toString())

      console.log("Minting NFT...");
      
      // mintLaunchpad 함수 호출
      const tx = await championGachaChestNFT.mintNFT(recipientAddress, {gasLimit: manualGasLimit});
      
      // 트랜잭션 대기
      const receipt = await tx.wait();
      
      // 민팅된 토큰 ID 가져오기
      const mintEvent = receipt.events?.find(event => event.event === 'TransferSingle');
      const tokenId = mintEvent?.args?.id;
  
      console.log(`Successfully minted NFT with token ID ${tokenId} to ${recipientAddress}`);
  
      // 토큰 URI 확인
      const tokenURI = await championGachaChestNFT.uri(tokenId);
      console.log(`Token URI: ${tokenURI}`);
  
    } catch (error) {
      console.error("Error minting NFT:", error);
    }
  }
  
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });