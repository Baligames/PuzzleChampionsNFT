import { expect } from "chai";
import { ethers } from "hardhat";
import { PuzzleChampionsNFT__factory } from "../../scripts/typechain-types/factories/src/mock/PuzzleChampionsNFT__factory";

const name = "PuzzleChampionsNFT";
const symbol = "PUZZ_CHAMP";
const baseURI = "https://nft.axie-champions.com/";

describe("PUZZ_CHAMP", function () {
  it("Should return name PUZZ_CHAMP", async function () {
    const [deployer] = await ethers.getSigners();
    const Token = new PuzzleChampionsNFT__factory(deployer);
    //const token = await Token.deploy(name, symbol, baseURI);
    const token = await Token.deploy();
    await token.deployed();

    expect(await token.name()).to.equal(name);
  });
});
