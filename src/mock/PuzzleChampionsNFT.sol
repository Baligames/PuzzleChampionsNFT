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
    uint256 public constant FUSION_CORE_ID = 2;

    uint256 public constant CAPSULE_TYPE1_ID = 1001;
    uint256 public constant CAPSULE_TYPE2_ID = 1002;
    uint256 public constant CAPSULE_TYPE3_ID = 1003;
    uint256 public constant CAPSULE_TYPE4_ID = 1004;
    uint256 public constant CAPSULE_TYPE5_ID = 1005;

    uint256 public constant CHAMPIONS_MIN_ID = 100001;
    uint256 public constant CHAMPIONS_MAX_ID = 999_999_999;
    // champions count, 액쳄 머신 민팅으로 195936 -> 999_999_999 로 확장 (2024.12.26)
    // AXC(액챔) 에서 머신 소각해서 민팅하는 머신들(5,6성)은 200000 ~ 299999 번 범위로 민팅, 약 21000개 정도 일정에 따라 소폭 증가
    uint256 public constant CHAMPIONS_FUSION_ID_MIN = 1_000_001; // fusion mint 된 챔피언 1_000_001 ~ 부터 시작
    uint256 public constant CHAMPIONS_SILVER_ID_MAX = 134986; // silver 100001 ~ 134986

    // NFT ID에 대한 메타데이터 URI 매핑
    mapping(uint256 => string) private _metadataURIs;

    // Champion 민팅 어드레스 매핑
    mapping(uint256 => address) private _mintedChampionAddresses;

    // 기본 URI
    string private _baseURI;
    string private _name;
    string private _symbol;
    uint8 private _dev = 0; // 0: prod, 1: dev

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

        string memory metadataFusionCoreURI = string(abi.encodePacked(_baseURI, "fusioncore/", FUSION_CORE_ID.toString(), ".json")); 
        _setMetadataURI(FUSION_CORE_ID, metadataFusionCoreURI);

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

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        _baseURI = newBaseURI;
    }

    function _setMetadataURI(uint256 tokenId, string memory metadataURI) internal virtual {
        _metadataURIs[tokenId] = metadataURI;
    }

    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        string memory metadataURI = _metadataURIs[tokenId];
        string memory token_type;
        string memory envQuery = "";

        if (tokenId == CHEST_ID) {
            token_type = "chest";
        } else if (tokenId == FUSION_CORE_ID) {
            token_type = "fusioncore";
        } else if (tokenId >= CAPSULE_TYPE1_ID && tokenId <= CAPSULE_TYPE5_ID) {
            token_type = "capsule";
        } else {
            token_type = "champions";
        }

        if (_dev == 1) {
            envQuery = string(abi.encodePacked("?env=dev"));
        }

        return bytes(metadataURI).length > 0
            ? string(abi.encodePacked(metadataURI, envQuery))
            : string(abi.encodePacked(_baseURI, token_type, "/", tokenId.toString(), ".json", envQuery));
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

    function mintFusionCore(address to, uint256 quantity, bytes memory data) external virtual onlyProxyAdmin
    {
        _mint(to, FUSION_CORE_ID, quantity, data);
    }

    // Burn one chest owned by the given address and mint one capsule.
    function mintCapsule(address to, uint256 capsuleId, uint256 quantity, bytes memory data) external virtual onlyProxyAdmin
    {
        //require(balanceOf(to, CHEST_ID) > 0, "Address must own at least one CHEST"); // no more need to check chest
        require(CAPSULE_TYPE1_ID <= capsuleId && capsuleId <= CAPSULE_TYPE5_ID, "capsule id exceeds capsule type range");

        // Burn one CHEST_ID from the address
        //_burn(to, CHEST_ID, 1);

        _mint(to, capsuleId, quantity, data);
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
        _mintedChampionAddresses[championId] = address(0);
    }

    // 소유한 Champion ID를 반환하는 함수
    function getOwnedChampions(address owner) external view virtual returns (uint256[] memory) {
        return _ownedChampions[owner];
    }

    // 소유한 CHEST 와 CAPSULE 의 갯수를 반환
    function getOwnedCapsule(address owner) external view virtual returns (uint256[] memory ownedCounts) {

        ownedCounts = new uint256[](6);
        ownedCounts[0] = balanceOf(owner, FUSION_CORE_ID);
        ownedCounts[1] = balanceOf(owner, CAPSULE_TYPE1_ID);
        ownedCounts[2] = balanceOf(owner, CAPSULE_TYPE2_ID);
        ownedCounts[3] = balanceOf(owner, CAPSULE_TYPE3_ID);
        ownedCounts[4] = balanceOf(owner, CAPSULE_TYPE4_ID);
        ownedCounts[5] = balanceOf(owner, CAPSULE_TYPE5_ID);

    }

    // Fusion core 1개와 기존 champion 2개를 소모하고 새로운 champion 1개를 발급
    function fusionChampion(address to, uint256 fusionCoreCount, uint256[] memory championIds, uint256 targetChampionId, bytes memory data) external virtual onlyProxyAdmin {
        require(balanceOf(to, FUSION_CORE_ID) >= fusionCoreCount, "Address must own at least one Fusion Core");
        require(balanceOf(to, championIds[0]) > 0, "Address must own Champion (index 0) for burning");
        require(balanceOf(to, championIds[1]) > 0, "Address must own Champion (index 1) for burning");
        // targetChampionId 은 아무도 소유하지 않은 챔피언이어야 함.
        require(targetChampionId >= CHAMPIONS_FUSION_ID_MIN, "Target Champion ID must be greater than CHAMPIONS_FUSION_ID_MIN");
        require(_mintedChampionAddresses[targetChampionId] == address(0), "Target Champion ID already minted to an address");

        /*  1성 → 2성 : 퓨전코어 2 EA 소모 - 퓨전 불가
            2성 → 3성 : 퓨전코어 5 EA 소모
            3성 → 4성 : 퓨전코어 10 EA 소모
            4성 → 5성 : 퓨전코어 20 EA 소모
            5성 → 6성 : 퓨전코어 40 EA 소모 */

        // burn 3 items
        _burn(to, FUSION_CORE_ID, fusionCoreCount);
        _removeChampionFromOwner(to, championIds[0]);
        _burn(to, championIds[0], 1);
        _removeChampionFromOwner(to, championIds[1]);
        _burn(to, championIds[1], 1);

        // mint target champion
        string memory metadataURI = string(abi.encodePacked(_baseURI, "champions/", targetChampionId.toString(), ".json")); 
        _setMetadataURI(targetChampionId, metadataURI);

        _mintedChampionAddresses[targetChampionId] = to; // Record the address that receives the NFT
        _addChampionToOwner(to, targetChampionId);
        _mint(to, targetChampionId, 1, data);
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
            _mintedChampionAddresses[id] = to;
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
                _mintedChampionAddresses[ids[i]] = to;
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

    function setFusionCoreMetadata() external virtual onlyProxyAdmin {
        string memory metadataFusionCoreURI = string(abi.encodePacked(_baseURI, "fusioncore/", FUSION_CORE_ID.toString(), ".json"));
        _setMetadataURI(FUSION_CORE_ID, metadataFusionCoreURI);
    }

    function setDev(uint8 dev) external virtual onlyProxyAdmin {
        _dev = dev;
    }

}
