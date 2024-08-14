import { expect } from "chai";
import { ethers } from "hardhat";
import { ChampionChestNFT__factory } from "../../scripts/typechain-types/factories/src/mock/ChampionChestNFT__factory";

const name = "ChampionChestNFT";
const symbol = "CHAMP_CHEST";
const baseURI = "https://nft.axie-champions.com/";

describe("CHAMP_CHEST", function () {
  it("Should return name CHAMP_CHEST", async function () {
    const [deployer] = await ethers.getSigners();
    const Token = new ChampionChestNFT__factory(deployer);
    //const token = await Token.deploy(name, symbol, baseURI);
    const token = await Token.deploy();
    await token.deployed();

    expect(await token.name()).to.equal(name);
  });
});
