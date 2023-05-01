// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract BrandingUpgradeable is Initializable, AccessControlUpgradeable {
    // must be declared
    uint128 brandFee;

    bytes16 BRAND_ADMIN = bytes16(keccak256("BRAND_ADMIN"));
    bytes16 BRAND_MANAGER = bytes16(keccak256("BRAND_MANAGER"));

    uint128 nextBrandId = 0;
    struct brand  {
        string name;
        string uri;
        uint128[] tokenIds;
    }
    mapping(uint128 => brand) private brandMap;

    constructor() {
        _disableInitializers();
    }

    // helper function for calculating (concatenating) roles
    function figureRole(uint128 _brandId, bytes16 _halfHashedRole) internal pure returns (bytes32) {
        bytes memory packed = abi.encodePacked(bytes16(_brandId), _halfHashedRole);
        bytes32 result;
        assembly { result := mload(add(packed, 32)) }
        return result;
    }

    // restricts Access to Administrators of a Brand
    modifier onlyBrandAdmin(uint128 _brandId) {
        _checkRole(getBRAND_ADMIN(_brandId));
        _;
    }

    // restricts Access to Managers of a Brand
    modifier onlyBrandManager(uint128 _brandId) {
        _checkRole(figureRole(_brandId, BRAND_MANAGER));
        _;
    }


    function createBrand(string memory _name, string memory _uri) public payable {
        require(msg.value >= brandFee, "Insufficiant payment");
        require(bytes(_name ).length != 0);
        brandMap[nextBrandId].name = _name;
        brandMap[nextBrandId].uri = _uri;
        _setupRole(figureRole(nextBrandId, bytes16(keccak256("BRAND_ADMIN"))), msg.sender);
        _setupRole(figureRole(nextBrandId, bytes16(keccak256("BRAND_MANAGER"))), msg.sender);
        nextBrandId ++;
        // MUST trigger event
    }

    function updateBranding(uint128 _brandId, string memory _name, string memory _uri) public onlyBrandManager(_brandId) {
        brandMap[_brandId].name = _name;
        brandMap[_brandId].uri = _uri;
        // MUST trigger event
    }

    function readBranding(uint128 _brandId) public view returns (string memory, string memory) {
        return (brandMap[_brandId].name,
        brandMap[_brandId].uri);
    }

    function initialize() public virtual initializer {
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(figureRole(0, BRAND_MANAGER), msg.sender);
        createBrand("Dyvvy Nation", "https://dyvvy.org");
    }

    function getBRAND_ADMIN(uint128 _brandId) public view returns (bytes32) {
        return figureRole(_brandId, BRAND_ADMIN);
    }

    function getBRAND_MANAGER(uint128 _brandId) public view returns (bytes32) {
        return figureRole(_brandId, BRAND_MANAGER);
    }

    function setBRAND_MANAGER(uint128 _brandId, address _assignee) public onlyBrandAdmin(_brandId) {
        _setupRole(figureRole(_brandId, BRAND_MANAGER), _assignee);
    } 
    
    function setBRAND_ADMIN(uint128 _brandId, address _assignee) public onlyBrandAdmin(_brandId) {
        _setupRole(figureRole(_brandId, BRAND_ADMIN), _assignee);
    } 

    function revokeManagerRole(uint128 _brandId, address _assignee) public onlyBrandAdmin(_brandId) {
        _revokeRole(figureRole(_brandId, BRAND_MANAGER), _assignee);
    }

    function transferAndRevokeBrandAdmin(uint128 _brandId, address _newOwner) public payable onlyBrandAdmin(_brandId) {
        _setupRole(getBRAND_ADMIN(_brandId), _newOwner);
        renounceRole(getBRAND_ADMIN(_brandId), msg.sender);
        // MUST trigger event (i think is does with renouncRole()
    }
}
