// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


// add events and comments
import "./SubletControlUpgradeable.sol";

abstract contract BrandingSubletUpgradeable is SubletControlUpgradeable {
    // must be declared
    uint128 brandFee;

    uint128 nextBrandId;
    struct brand  {
        string name;
        string uri;
        uint128[] uriIds;
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


    function createBrand(string memory _name, string memory _uri) public payable returns (uint128) {
        require(msg.value >= brandFee, "Insufficiant payment");
        require(bytes(_name ).length != 0);
        brandMap[nextBrandId].name = _name;
        brandMap[nextBrandId].uri = _uri;
        _setupRole(getRole(nextBrandId, "BRAND_ADMIN"), msg.sender);
        _setupRole(getRole(nextBrandId, "BRAND_MANAGER"), msg.sender);
        nextBrandId ++;
        return nextBrandId - 1;
        // MUST trigger event
    }

    function updateBranding(uint128 _brandId, string memory _name, string memory _uri) public onlyBrandManager(_brandId) returns (bool) {
        brandMap[_brandId].name = _name;
        brandMap[_brandId].uri = _uri;
        // MUST?SHOULD? trigger event
        return true;
    }

    function readBranding(uint128 _brandId) public view returns (string memory, string memory URI, uint128[] memory Tokens, bytes32 BRAND_ADMIN, bytes32 BRAND_MANAGER) {
        return (brandMap[_brandId].name,
        brandMap[_brandId].uri,
        brandMap[_brandId].uriIds,
        getRole(_brandId, "BRAND_ADMIN"),
        getRole(_brandId, "BRAND_MANAGER"));
    }

    function setBRAND_MANAGER(uint128 _brandId, address _assignee) public onlyBrandAdmin(_brandId) returns (bool) {
        _setupRole(getRole(_brandId, "BRAND_MANAGER"), _assignee);
        return true;
    } 
    
    function setBRAND_ADMIN(uint128 _brandId, address _assignee) public onlyBrandAdmin(_brandId) returns (bool) {
        _setupRole(getRole(_brandId, "BRAND_ADMIN"), _assignee);
        return true;
    } 

    function transferAndRenounceBrandAdmin(uint128 _brandId, address _newOwner) public onlyBrandAdmin(_brandId) returns (bool) {
        _setupRole(getRole(_brandId, "BRAND_ADMIN"), _newOwner);
        renounceRole(getRole(_brandId, "BRAND_ADMIN"), msg.sender);
        return true;
        // MUST trigger event (ACU renounceRole() might do this already)
    }

    // Brands may claim batches of uriIds which share a uri, saving storage and gas fees to store once per batch uri

    uint128 _nextUriId;
    struct uriHelper {
        uint128 upperLimit;
        string uri;
    }
    mapping(uint128 => uriHelper) internal uriMap;

    // Functions
    function batchURI(uint128 _uriId) public returns (string memory) {
        require(_exists(_uriId) == true, "Nonexistent token");
        return bytes(_baseURI(_uriId)).length != 0 ? string(abi.encodePacked(_baseURI(_uriId), "/", _uriId)) : '';
    }

    function _baseURI(uint128 _uriId) internal view returns (string memory) {
        uint128 lowerLimit = 0;
        while (lowerLimit < _nextUriId) {
            if(lowerLimit <= _uriId && _uriId < uriMap[lowerLimit].upperLimit) break;
            lowerLimit = uriMap[lowerLimit].upperLimit;
        }
        return uriMap[lowerLimit].uri;
    }

    // MUST only update existing entries
    function updateBatchofURIs(uint128 _lowerLimit, string memory _newURI) public onlyRole(getRole(_lowerLimit, "BRAND_MANAGER")) {
        if(bytes(uriMap[_lowerLimit].uri).length !=0) uriMap[_lowerLimit].uri = _newURI;
    }

    // MUST only update ONE 'tuple'
    function allocateAndSetURIs(uint128 quantity, string memory uri) public onlyRole(getRole(_nextUriId, "BRAND_MANAGER")) virtual {
        require(quantity>0);
        uriMap[_nextUriId] = uriHelper(_nextUriId + quantity,uri);
    }

    function _exists(uint128 _uriId) internal returns (bool) {

    }
}
