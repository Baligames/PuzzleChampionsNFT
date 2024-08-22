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


contract ChampionGachaChestNFT is Initializable, ERC1155Upgradeable, OwnableUpgradeable, UUPSUpgradeable, AccessControl, NFTLaunchpadCommon {

    using Counters for Counters.Counter;
    using Strings for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public constant CHEST = 1;

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
            "image": "https://images.axie-champions.com/chest.png",
            "attributes": [
                {"display_type":"string","trait_type":"Gacha Class","value":"normal"},
            ]
        }
    */

    function initialize(address admin, address minter) initializer public {
        __ERC1155_init("");
        __Ownable_init();
        __UUPSUpgradeable_init();
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(MINTER_ROLE, minter);
        _baseURI = "https://nft.axie-champions.com/metadata/";

        string memory metadataURI = string(abi.encodePacked(_baseURI, "chest/", CHEST.toString(), ".json")); 
        _setTokenURI(CHEST, metadataURI);
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        _baseURI = newBaseURI;
    }

    function _setTokenURI(uint256 tokenId, string memory metadataURI) internal virtual {
        _tokenURIs[tokenId] = metadataURI;
    }

    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        string memory tokenURI = _tokenURIs[tokenId];
        
        return bytes(tokenURI).length > 0
            ? tokenURI
            : string(abi.encodePacked(_baseURI, "chest/", tokenId.toString(), ".json"));
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        virtual
        onlyRole(MINTER_ROLE)
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        _mintBatch(to, ids, amounts, data);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function mintNFT(address account) public virtual onlyRole(MINTER_ROLE) {
        _mint(account, CHEST, 1, "");
    }

    /// @dev Mint NFTs for the launchpad.
    function mintLaunchpad(address to, uint256 quantity, bytes calldata /* extraData */ )
        external
        virtual
        onlyRole(MINTER_ROLE)
        returns (uint256[] memory tokenIds, uint256[] memory amounts)
    {
        require(quantity == 1, "Only one Chest NFT can be minted at a time");

        tokenIds = new uint256[](1);
        amounts = new uint256[](1);
        tokenIds[0] = CHEST;
        amounts[0] = 1;

        _mint(to, CHEST, 1, "");

        return (tokenIds, amounts);

    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155Upgradeable, AccessControl, NFTLaunchpadCommon)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _msgSender() internal view virtual override(Context, ContextUpgradeable) returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual override(Context, ContextUpgradeable) returns (bytes calldata) {
        return msg.data;
    }
}
