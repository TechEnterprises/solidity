// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


// add events and comments
import "./SubletControlUpgradeable.sol";

contract BrandingSubletUpgradeable is SubletControlUpgradeable {
    // must be declared
    uint128 brandFee;

    uint128 nextBrandId;
    struct brand  {
        string name;
        string uri;
        uint128[] tokenIds;
    }
    mapping(uint128 => brand) private brandMap;

      // restricts Access to Administrators of a Brand
    modifier onlyBrandAdmin(uint128 _brandId) {
        _checkRole(getRole(_brandId, "BRAND_MANAGER"));
        _;
    }

    // restricts Access to Managers of a Brand
    modifier onlyBrandManager(uint128 _brandId) {
        _checkRole(getRole(_brandId, "BRAND_MANAGER"));
        _;
    }


    function createBrand(string memory _name, string memory _uri) public payable {
        require(msg.value >= brandFee, "Insufficiant payment");
        require(bytes(_name ).length != 0);
        brandMap[nextBrandId].name = _name;
        brandMap[nextBrandId].uri = _uri;
        _setupRole(getRole(nextBrandId, "BRAND_ADMIN"), msg.sender);
        _setupRole(getRole(nextBrandId, "BRAND_MANAGER"), msg.sender);
        nextBrandId ++;
        // MUST trigger event
    }

    function updateBranding(uint128 _brandId, string memory _name, string memory _uri) public onlyBrandManager(_brandId) {
        brandMap[_brandId].name = _name;
        brandMap[_brandId].uri = _uri;
        // MUST?SHOULD? trigger event
    }

    function readBranding(uint128 _brandId) public view returns (string memory, string memory URI, uint128[] memory Tokens, bytes32 ADMIN_ROLE, bytes32 MANAGER_ROLE) {
        return (brandMap[_brandId].name,
        brandMap[_brandId].uri,
        brandMap[_brandId].tokenIds,
        getRole(_brandId, "BRAND_ADMIN"),
        getRole(_brandId, "BRAND_MANAGER"));
    }

    function setBRAND_MANAGER(uint128 _brandId, address _assignee) public onlyBrandAdmin(_brandId) {
        _setupRole(getRole(_brandId, "BRAND_MANAGER"), _assignee);
    } 
    
    function setBRAND_ADMIN(uint128 _brandId, address _assignee) public onlyBrandAdmin(_brandId) {
        _setupRole(getRole(_brandId, "BRAND_ADMIN"), _assignee);
    } 

    function transferAndRenounceBrandAdmin(uint128 _brandId, address _newOwner) public onlyBrandAdmin(_brandId) {
        _setupRole(getRole(_brandId, "BRAND_ADMIN"), _newOwner);
        renounceRole(getRole(_brandId, "BRAND_ADMIN"), msg.sender);
        // MUST trigger event (i think is does with renouncRole()
    }
}
