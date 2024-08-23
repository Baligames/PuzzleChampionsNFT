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

    function mintLaunchpad(address to, uint256 quantity, bytes calldata /* extraData */ )
        external
        override
        onlyRole(MINTER_ROLE)
        returns (uint256[] memory tokenIds, uint256[] memory amounts)
    {
        tokenIds = new uint256[](1);
        amounts = new uint256[](1);
        tokenIds[0] = CHEST;
        amounts[0] = quantity;

        _mint(to, CHEST, quantity, "");

        return (tokenIds, amounts);

    }

}
