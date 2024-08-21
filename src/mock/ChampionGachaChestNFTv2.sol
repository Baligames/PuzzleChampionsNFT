// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import { NFTLaunchpadCommon } from "../launchpad/NFTLaunchpadCommon.sol";
import { AccessControl, Context } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ChampionGachaChestNFT } from "./ChampionGachaChestNFT.sol";


contract ChampionGachaChestNFTv2 is ChampionGachaChestNFT {

    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIds;

    // 토큰 ID에 대한 메타데이터 URI 매핑
    mapping(uint256 => string) private _tokenURIs;

    // 기본 URI
    string private _baseURI;

    /// @custom:oz-upgrades-unsafe-allow constructor
    //constructor() ERC1155Upgradeable() {
    //    _disableInitializers();
    //}
    /*
        metadata sample:
        {
            "name": "Champion Gacha Chest NFT",
            "description": "This is a unique NFT with cool properties",
            "image": "https://images.axie-champions.com/chest.png",
            "attributes": [
                {"chest_type": "gacha", "value": "normal"}
            ]
        }
    */

    /// @dev Mint NFTs for the launchpad.
    function mintLaunchpad(address to, uint256 quantity, bytes calldata /* extraData */ )
        external
        onlyRole(MINTER_ROLE)
        override
        returns (uint256[] memory tokenIds, uint256[] memory amounts)
    {
        require(quantity == 1, "Only one Chest NFT can be minted at a time");

        uint256 newTokenId = _tokenIds.current();
        _mint(to, newTokenId, 1, "");

        string memory metadataURI = string(abi.encodePacked(_baseURI, "chest/v2/", newTokenId.toString(), ".json")); 
        _setTokenURI(newTokenId, metadataURI);

        tokenIds = new uint256[](1);
        amounts = new uint256[](1);
        tokenIds[0] = newTokenId;
        amounts[0] = 1;
        _tokenIds.increment();

        return (tokenIds, amounts);

    }

}
