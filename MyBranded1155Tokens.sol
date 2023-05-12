// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./extensions/BrandingSubletUpgradeable.sol";
import "./extensions/TokenSubletUpgradeable.sol";
import "./extensions/TrustlessTokens.sol";

contract MyBranded1155Tokens is Initializable, TrustlessTokens,  ERC1155Upgradeable,UUPSUpgradeable, BrandingSubletUpgradeable, TokenSubletUpgradeable {
// AccessControl

    uint128 nextClaimId;
    uint128 tokenFee;

// constructor(), initialize(), Interface
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        initialize();
        _disableInitializers();
    }

    function initialize() initializer public {
        __ERC1155_init("Sublet Tokens");
        __UUPSUpgradeable_init();
        __AccessControl_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        grantRole(getRole(0, "BRAND_ADMIN"), msg.sender);
        grantRole(getRole(0, "BRAND_MANAGER"), msg.sender);
        // make certain the Admin role is Admin of the other two following token roles
        grantRole(getRole(0, "TOKEN_ADMIN"), msg.sender);
        grantRole(getRole(0, "TOKEN_URI_SETTER"), msg.sender);
        grantRole(getRole(0, "TOKEN_MINTER"), msg.sender);

        createBrand("Sublet Nation", "https://sublet.org");
        brandFee = 150000000000000000;
        tokenFee = 100000000000000000;
    }

    
    mapping(uint128 => TrustlessTokenData) private tokenMap;

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlUpgradeable, ERC1155Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    //uri
    function _setURI(uint128 _tokenId, string memory _newuri) // must account for batches
        internal virtual onlyRole(getRole(_tokenId, "TOKEN_URI_SETTER")) {
            tokenMap[_tokenId].tokenUri = _newuri;
        }
    
    function _setBatchURI() internal {}

    function uri(uint128 _tokenId) public view returns (string memory) {
        return tokenMap[_tokenId].tokenUri;
    }

    // Set Claims
    function lazyMintUnbrandedToken(
            string memory _name, 
            string memory _uri, 
            uint128 _factoryPrice, 
            uint128 _maxSupply) 
        public payable returns (uint128) {
            require(msg.value >= tokenFee, "Insufficient payment.");
            _setupRole(getRole(nextClaimId, "TOKEN_URI_SETTER"), msg.sender);
            grantRole(getRole(nextClaimId, "TOKEN_MINTER"), msg.sender);
            tokenMap[nextClaimId].tokenName = _name;
            tokenMap[nextClaimId].tokenUri = _uri;
            tokenMap[nextClaimId].ownerBrandId = 0xffffffffffffffff;
            tokenMap[nextClaimId].currentMintingPrice = _factoryPrice;
            tokenMap[nextClaimId].maxSupplyQty = _maxSupply;
            nextClaimId++;
            return nextClaimId - 1;
        }

    function lazyMintBrandedToken(
            uint128 _brandId, 
            string memory _name, 
            string memory _uri, 
            uint128 _factoryPrice, 
            uint128 _maxSupply) 
        public payable returns (uint128) {
            require(bytes(_name).length != 0, "Must include a 'Name'");
            require(msg.value >= tokenFee, "Insufficient payment.");
            _setupRole(getRole(nextClaimId, "TOKEN_URI_SETTER"), msg.sender);
            grantRole(getRole(nextClaimId, "TOKEN_MINTER"), msg.sender);
            tokenMap[nextClaimId].tokenName = _name;
            tokenMap[nextClaimId].tokenUri = _uri;
            tokenMap[nextClaimId].ownerBrandId = _brandId;
            tokenMap[nextClaimId].currentMintingPrice = _factoryPrice;
            tokenMap[nextClaimId].maxSupplyQty = _maxSupply;
            nextClaimId++;
            return nextClaimId - 1;
        }

    function lazyMintBrandedTokens(
            string[] memory _names, 
            string memory _uris, 
            uint128 _brandId, 
            uint128[] memory _factoryPrices, 
            uint128[] memory _maxSupplies) 
        public payable onlyBrandManager(_brandId) returns (uint128) {
            require(msg.value >= tokenFee, "Insufficient payment."); // there is a payment backdoor here where you can pay much less
        
            for(uint128 i=0; i<_names.length; i++) {
                _setupRole(getRole(nextClaimId, "TOKEN_URI_SETTER"), msg.sender);
                grantRole(getRole(nextClaimId, "TOKEN_MINTER"), msg.sender);
                tokenMap[nextClaimId].tokenName = _names[i];
                tokenMap[nextClaimId].tokenUri = _uris;  // we actually want batchURIs here not repetative...
                tokenMap[nextClaimId].ownerBrandId = _brandId;
                tokenMap[nextClaimId].currentMintingPrice = _factoryPrices[i];   
                tokenMap[nextClaimId].maxSupplyQty = _maxSupplies[1];
                nextClaimId++;
            }
            return nextClaimId - 1;
        }

    // Minting and LazyMinting
    // if caller is TOKEN_MINTER and MaxSupply is not locked they will be allowed to exceed/raise the MaxSupply automatically

    function mint(
            address _account, 
            uint128 _id, 
            uint128 _amount, 
            bytes memory _data)
        public {
            uint128 newSupply = tokenMap[_id].qtyMinted + _amount - tokenMap[_id].qtyBurned;
            if(hasRole(getRole(tokenMap[_id].ownerBrandId, "TOKEN_MINTER"), msg.sender ) && tokenMap[_id].isSupplyLocked == false)  {
                if(tokenMap[_id].maxSupplyQty > (newSupply)) {
                    tokenMap[_id].maxSupplyQty = newSupply;
                }
            }
            require(tokenMap[_id].maxSupplyQty >= (newSupply), "Exceeds max supply");
            _mint(_account, _id, _amount, _data);
        }

    function mintBatch(address _to, uint128[] memory _ids, uint128[] memory _amounts, bytes memory _data)
        public {
            for(uint128 i = 0; i<_ids.length; i++) {
                uint128 newSupply = tokenMap[i].qtyMinted + _amounts[i] - tokenMap[i].qtyBurned;
                if(hasRole(getRole(_ids[i],"TOKEN_MINTER"), msg.sender)) {
                    if(tokenMap[_ids[i]].maxSupplyQty > (newSupply)) tokenMap[_ids[i]].maxSupplyQty = newSupply;
                }
                require(tokenMap[_ids[i]].maxSupplyQty >= (tokenMap[_ids[i]].qtyMinted - tokenMap[_ids[i]].qtyBurned), "Exceeds max supply");
                _mint(_to, uint256(_ids[i]), _amounts[i], _data);
            }
        }

    function _authorizeUpgrade(address newImplementation)
        internal onlyRole("DEFAULT_ADMIN_ROLE") override {}

    
    function paused(uint128 _tokenId) public view returns (bool) {
        if(tokenMap[_tokenId].isPausable == false || tokenMap[_tokenId].isPaused == false) {
            return false;
        }
        return true;
    }

    function paused(uint256 _tokenId) public view returns (bool) {
        uint128 newId = uint128(_tokenId);
        if(tokenMap[newId].isPausable == false || tokenMap[newId].isPaused == false) {
            return false;
        }
        return true;
    }

    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );

        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );

        _burnBatch(account, ids, values);
    }
}
