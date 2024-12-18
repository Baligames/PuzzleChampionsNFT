// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

//import { NFTLaunchpadCommon } from "../launchpad/NFTLaunchpadCommon.sol";
//import { AccessControl, Context } from "@openzeppelin/contracts/access/AccessControl.sol";
contract PuzzleChampionsNFT is Initializable, ERC1155Upgradeable, OwnableUpgradeable, UUPSUpgradeable {

    using Strings for uint256;

    address private proxyAdmin;

    uint256 public constant CHEST_ID = 1;

    uint256 public constant CAPSULE_TYPE1_ID = 1001;
    uint256 public constant CAPSULE_TYPE2_ID = 1002;
    uint256 public constant CAPSULE_TYPE3_ID = 1003;
    uint256 public constant CAPSULE_TYPE4_ID = 1004;
    uint256 public constant CAPSULE_TYPE5_ID = 1005;

    uint256 public constant CHAMPIONS_MIN_ID = 100001;
    uint256 public constant CHAMPIONS_MAX_ID = 999999;
    // champions count, 액쳄 머신 민팅으로 195936 -> 999999 로 확장 (2024.12.12)
    // AXC(액챔) 에서 머신 소각해서 민팅하는 머신들(5,6성)은 200000 ~ 299999 번 범위로 민팅, 약 21000개 정도 일정에 따라 소폭 증가

    uint256 public constant CHAMPIONS_SILVER_ID_MAX = 134986; // silver 100001 ~ 134986

    // NFT ID에 대한 메타데이터 URI 매핑
    mapping(uint256 => string) private _metadataURIs;

    // Champion 민팅 어드레스 매핑
    mapping(uint256 => address) private _mintedChampionAddresses;

    // 기본 URI
    string private _baseURI;
    string private _name;
    string private _symbol;

    // 각 주소가 소유한 Champion ID를 저장하는 매핑
    mapping(address => uint256[]) private _ownedChampions;

    // Champion ID를 소유한 주소의 인덱스를 저장하는 매핑
    mapping(uint256 => uint256) private _ownedChampionIndex;

    function initialize(string memory tokenName, string memory tokenSymbol, address _proxyAdmin) initializer public {
        __ERC1155_init("");
        __Ownable_init();
        __UUPSUpgradeable_init();
        //_setupRole(DEFAULT_ADMIN_ROLE, admin);
        //_setupRole(MINTER_ROLE, minter);
        //_chestIds.increment();
        _baseURI = "https://meta.baligames.net/";
        _name = tokenName;
        _symbol = tokenSymbol;
        proxyAdmin = _proxyAdmin;

        // set metadata uri for chest and capsules
        string memory metadataChestURI = string(abi.encodePacked(_baseURI, "chest/", CHEST_ID.toString(), ".json")); 
        _setMetadataURI(CHEST_ID, metadataChestURI);

        string memory metadataCapsule1URI = string(abi.encodePacked(_baseURI, "capsule/", CAPSULE_TYPE1_ID.toString(), ".json")); 
        _setMetadataURI(CAPSULE_TYPE1_ID, metadataCapsule1URI);

        string memory metadataCapsule2URI = string(abi.encodePacked(_baseURI, "capsule/", CAPSULE_TYPE2_ID.toString(), ".json")); 
        _setMetadataURI(CAPSULE_TYPE2_ID, metadataCapsule2URI);

        string memory metadataCapsule3URI = string(abi.encodePacked(_baseURI, "capsule/", CAPSULE_TYPE3_ID.toString(), ".json")); 
        _setMetadataURI(CAPSULE_TYPE3_ID, metadataCapsule3URI);

        string memory metadataCapsule4URI = string(abi.encodePacked(_baseURI, "capsule/", CAPSULE_TYPE4_ID.toString(), ".json")); 
        _setMetadataURI(CAPSULE_TYPE4_ID, metadataCapsule4URI);

        string memory metadataCapsule5URI = string(abi.encodePacked(_baseURI, "capsule/", CAPSULE_TYPE5_ID.toString(), ".json")); 
        _setMetadataURI(CAPSULE_TYPE5_ID, metadataCapsule5URI);
    }

    // Proxy 관리자만 접근할 수 있는 modifier
    modifier onlyProxyAdmin() {
        require(msg.sender == proxyAdmin, "Not authorized: Only proxy admin can call this function");
        _;
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        _baseURI = newBaseURI;
    }

    function _setMetadataURI(uint256 tokenId, string memory metadataURI) internal virtual {
        _metadataURIs[tokenId] = metadataURI;
    }

    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        string memory metadataURI = _metadataURIs[tokenId];
        
        return bytes(metadataURI).length > 0
            ? metadataURI
            : string(abi.encodePacked(_baseURI, "champions/", tokenId.toString(), ".json"));
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        virtual
        onlyProxyAdmin
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyProxyAdmin
    {
        _mintBatch(to, ids, amounts, data);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function mintChest(address to, uint256 quantity, bytes calldata /* extraData */ )
        external
        virtual
        onlyProxyAdmin
        returns (uint256[] memory tokenIds, uint256[] memory amounts)
    {

        _mint(to, CHEST_ID, quantity, "");

        tokenIds = new uint256[](1);
        amounts = new uint256[](1);
        tokenIds[0] = CHEST_ID;
        amounts[0] = quantity;

        return (tokenIds, amounts);

    }

    // Burn one chest owned by the given address and mint one capsule.
    function mintCapsule(address to, uint256 capsuleId ) external virtual onlyProxyAdmin
    {
        //require(balanceOf(to, CHEST_ID) > 0, "Address must own at least one CHEST"); // no more need to check chest
        require(CAPSULE_TYPE1_ID <= capsuleId && capsuleId <= CAPSULE_TYPE5_ID, "capsule id exceeds capsule type range");

        // Burn one CHEST_ID from the address
        //_burn(to, CHEST_ID, 1);

        _mint(to, capsuleId, 1, "");
    }

    // mint a champion NFT on address without burning capsule
    function mintChampionBatch(address to, uint256[] memory championIds, bytes memory data) external virtual onlyProxyAdmin {
        for (uint256 i = 0; i < championIds.length; ++i) {
            require(CHAMPIONS_MIN_ID <= championIds[i] && championIds[i] <= CHAMPIONS_MAX_ID, "Champion ID exceeds CHAMPIONS_MAX_ID");
            require(_mintedChampionAddresses[championIds[i]] == address(0), "Champion ID already minted to an address");
        }

        uint256[] memory amounts = new uint256[](championIds.length);

        for (uint256 i = 0; i < championIds.length; ++i) {
            uint256 championId = championIds[i];
            string memory metadataURI = string(abi.encodePacked(_baseURI, "champions/", championId.toString(), ".json")); 
            _setMetadataURI(championId, metadataURI);

            _mintedChampionAddresses[championId] = to; // Record the address that receives the NFT
            _addChampionToOwner(to, championId);
            amounts[i] = 1;
        }

        _mintBatch(to, championIds, amounts, data);

    }

    // mint a champion NFT on address
    function mintChampion(address to, uint256 capsuleId, uint256 championId) external virtual onlyProxyAdmin {
        require(CAPSULE_TYPE1_ID <= capsuleId && capsuleId <= CAPSULE_TYPE5_ID, "capsule id exceeds capsule type range");
        require(balanceOf(to, capsuleId) > 0, "Address must own at least one Capsule type");
        require(CHAMPIONS_MIN_ID <= championId && championId <= CHAMPIONS_MAX_ID, "Champion ID exceeds CHAMPIONS_MAX_ID");
        require(_mintedChampionAddresses[championId] == address(0), "Champion ID already minted to an address");

        // Burn one capsule from the address
        _burn(to, capsuleId, 1);

        string memory metadataURI = string(abi.encodePacked(_baseURI, "champions/", championId.toString(), ".json")); 
        _setMetadataURI(championId, metadataURI);

        _mintedChampionAddresses[championId] = to; // Record the address that receives the NFT
        _addChampionToOwner(to, championId);
        _mint(to, championId, 1, "");
    }

    // Champion 소각
    function burnChampion(address from, uint256 championId) external virtual onlyProxyAdmin {
        require(balanceOf(from, championId) > 0, "Address must own the Champion");
        _burn(from, championId, 1);
        _removeChampionFromOwner(from, championId);
    }

    // Champion ID를 민팅할 때 호출되는 함수
    function _addChampionToOwner(address owner, uint256 championId) internal {
        _ownedChampionIndex[championId] = _ownedChampions[owner].length;
        _ownedChampions[owner].push(championId);
    }

    // Champion ID를 소각할 때 호출되는 함수
    function _removeChampionFromOwner(address owner, uint256 championId) internal {
        require(_ownedChampions[owner][_ownedChampionIndex[championId]] == championId, "Champion not owned by address");

        uint256 lastIndex = _ownedChampions[owner].length - 1;
        uint256 championIndex = _ownedChampionIndex[championId];

        if (championIndex != lastIndex) {
            uint256 lastChampionId = _ownedChampions[owner][lastIndex];
            _ownedChampions[owner][championIndex] = lastChampionId;
            _ownedChampionIndex[lastChampionId] = championIndex;
        }

        _ownedChampions[owner].pop();
        delete _ownedChampionIndex[championId];
    }

    // 소유한 Champion ID를 반환하는 함수
    function getOwnedChampions(address owner) external view virtual returns (uint256[] memory) {
        return _ownedChampions[owner];
    }

    // 소유한 CHEST 와 CAPSULE 의 갯수를 반환
    function getOwnedCapsule(address owner) external view virtual returns (uint256[] memory ownedCounts) {

        ownedCounts = new uint256[](6);
        ownedCounts[0] = balanceOf(owner, CHEST_ID);
        ownedCounts[1] = balanceOf(owner, CAPSULE_TYPE1_ID);
        ownedCounts[2] = balanceOf(owner, CAPSULE_TYPE2_ID);
        ownedCounts[3] = balanceOf(owner, CAPSULE_TYPE3_ID);
        ownedCounts[4] = balanceOf(owner, CAPSULE_TYPE4_ID);
        ownedCounts[5] = balanceOf(owner, CAPSULE_TYPE5_ID);

    }

    // CAPSULE_TYPE1_ID trasnfer not allowed
    function safeTransferFrom(
        address from, address to, uint256 id, uint256 amount, bytes memory data
    ) public virtual override {
        require(id != CHEST_ID, "Transfer of CHEST is not allowed");
        require(id != CAPSULE_TYPE1_ID, "Transfer of CAPSULE_TYPE1_ID is not allowed");
        require(id < CHAMPIONS_MIN_ID || id > CHAMPIONS_SILVER_ID_MAX, "Transfer of Silver Champion is not allowed");

        // 소유권 변경
        if (id >= CHAMPIONS_MIN_ID) {
            _removeChampionFromOwner(from, id);
            _addChampionToOwner(to, id);
        }

        super.safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data
    ) public virtual override {
        for (uint256 i = 0; i < ids.length; ++i) {
            require(ids[i] != CHEST_ID, "Transfer of CHEST is not allowed");
            require(ids[i] != CAPSULE_TYPE1_ID, "Transfer of CAPSULE_TYPE1_ID is not allowed");
            require(ids[i] < CHAMPIONS_MIN_ID || ids[i] > CHAMPIONS_SILVER_ID_MAX, "Transfer of Silver Champion is not allowed");
        }

        for (uint256 i = 0; i < ids.length; ++i) {
            // 소유권 변경
            if (ids[i] >= CHAMPIONS_MIN_ID) {
                _removeChampionFromOwner(from, ids[i]);
                _addChampionToOwner(to, ids[i]);
            }
        }
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155Upgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _msgSender() internal view virtual override(ContextUpgradeable) returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual override(ContextUpgradeable) returns (bytes calldata) {
        return msg.data;
    }
}
