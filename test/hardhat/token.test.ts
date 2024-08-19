import { expect } from "chai";
import { ethers } from "hardhat";
import { ChampionGachaChestNFT__factory } from "../../scripts/typechain-types/factories/src/mock/ChampionGachaChestNFT__factory";

const name = "ChampionGachaChestNFT";
const symbol = "CHAMP_GACHA";
const baseURI = "https://nft.axie-champions.com/";

describe("CHAMP_GACHA", function () {
  it("Should return name CHAMP_GACHA", async function () {
    const [deployer] = await ethers.getSigners();
    const Token = new ChampionGachaChestNFT__factory(deployer);
    //const token = await Token.deploy(name, symbol, baseURI);
    const token = await Token.deploy();
    await token.deployed();

    expect(await token.name()).to.equal(name);
  });
});
