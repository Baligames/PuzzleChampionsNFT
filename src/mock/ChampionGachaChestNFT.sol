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

    Counters.Counter private _tokenIds;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public constant FT_ID = 1;
    uint256 public constant MINT_SIZE = 200000;
    uint256 public constant INITIAL_FT_SUPPLY = 100000000; // 1억 개의 초기 FT 공급량

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

    function initialize(address admin, address minter) initializer public {
        __ERC1155_init("");
        __Ownable_init();
        __UUPSUpgradeable_init();
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(MINTER_ROLE, minter);
        _tokenIds.increment(); // NFT ID 를 1부터 시작
        _mint(msg.sender, FT_ID, INITIAL_FT_SUPPLY, ""); // 1억 개의 FT를 owner에게 발행
        _baseURI = "https://nft.axie-champions.com/metadata/";
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

    function mintFT(address account, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(account, FT_ID, amount, "");
    }

    function mintNFT(address account) public onlyRole(MINTER_ROLE) returns (uint256) {
        uint256 newTokenId = _tokenIds.current();
        _mint(account, newTokenId, 1, "");
        _tokenIds.increment();
        return newTokenId;
    }

    /// @dev Mint NFTs for the launchpad.
    function mintLaunchpad(address to, uint256 quantity, bytes calldata /* extraData */ )
        external
        onlyRole(MINTER_ROLE)
        returns (uint256[] memory tokenIds, uint256[] memory amounts)
    {
        require(quantity == 1, "Only one Chest NFT can be minted at a time");

        uint256 newTokenId = _tokenIds.current();
        _mint(to, newTokenId, 1, "");

        string memory metadataURI = string(abi.encodePacked(_baseURI, "chest/", newTokenId.toString(), ".json")); 
        _setTokenURI(newTokenId, metadataURI);

        tokenIds = new uint256[](1);
        amounts = new uint256[](1);
        tokenIds[0] = newTokenId;
        amounts[0] = 1;
        _tokenIds.increment();

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
