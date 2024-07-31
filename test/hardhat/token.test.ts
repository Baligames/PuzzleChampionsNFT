import { expect } from "chai";
import { ethers } from "hardhat";
import { ChampionsNFT__factory } from "../../scripts/typechain-types/factories/src/mock/ChampionsNFT__factory";

const name = "ChampionsNFT";
const symbol = "CHAMP_NFT";
const baseURI = "https://nft.axie-champions.com/";

describe("CHAMP_NFT", function () {
  it("Should return name CHAMP_NFT", async function () {
    const [deployer] = await ethers.getSigners();
    const Token = new ChampionsNFT__factory(deployer);
    const token = await Token.deploy(name, symbol, baseURI);
    await token.deployed();

    expect(await token.name()).to.equal(name);
  });
});
