// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./ERC1155Subletting.sol";

abstract contract ERC1155BrandManagement is ERC1155Subletting{
    uint128 nextBrandId = 0;
    
    struct brandData {
        string brandName;
        address brandAdmin;
        string brandUri;
        uint128[] brandedTokenIds;
    }

    mapping(uint128 => brandData) brandDataMap;

    // expected needed modifiers
    modifier onlyBrandAdmin(uint128 brandId) {
        require(brandDataMap[brandId].brandAdmin == msg.sender, "Brand Administrator privelage required.");
        _;}
    modifier onlyBrandAdminOfToken(uint256 tokenId) {
        // require(token(exists));
        // getTokenBrand;
        // check Brand Admin against msg.sender;
        _;}

    function createBrand(string memory _brand, string memory _brandUri) public payable {
        // Set the next Brand's state
        brandDataMap[nextBrandId].brandName = _brand;
        brandDataMap[nextBrandId].brandAdmin = msg.sender;
        brandDataMap[nextBrandId].brandUri = _brandUri;
        // iterate counter
        nextBrandId++;
    }


}