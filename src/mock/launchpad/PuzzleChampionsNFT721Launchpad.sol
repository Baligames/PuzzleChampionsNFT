// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { PuzzleChampionsNFT } from "../PuzzleChampionsNFT.sol";
import "../../upgradeable/ERC721CommonUpgradeable.sol";
import { NFTLaunchpadCommon } from "../../launchpad/NFTLaunchpadCommon.sol";

contract PuzzleChampionsNFT721Launchpad is PuzzleChampionsNFT, NFTLaunchpadCommon {
  constructor(string memory name_, string memory symbol_, string memory uri_) PuzzleChampionsNFT() { }

  /// @dev Mint NFTs for the launchpad.
  function mintLaunchpad(address to, uint256 quantity, bytes calldata /* extraData */ )
    external
    onlyRole(MINTER_ROLE)
    returns (uint256[] memory tokenIds, uint256[] memory amounts)
  {
    tokenIds = new uint256[](quantity);
    amounts = new uint256[](quantity);
    for (uint256 i; i < quantity; ++i) {
      tokenIds[i] = _mintFor(to);
      amounts[i] = 1;
    }
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC721CommonUpgradeable, NFTLaunchpadCommon)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }
}