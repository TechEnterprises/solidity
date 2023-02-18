// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/access/AccessControl.sol";

bytes32 public constant URI_ROLE = keccak256("URI_ROLE");

abstract contract ERC721A_URISegmentation is AccessControl {
    function tokenURI(uint256 _tokenId) public view virtual override(ERC721A, IERC721A) returns (string memory) {
        if (!_exists(_tokenId)) revert URIQueryForNonexistentToken();
        return bytes(_baseURI(_tokenId)).length != 0 ? string(abi.encodePacked(_baseURI(_tokenId), "/", _toString(_tokenId))) : '';
    }

    function _baseURI(uint256 _tokenIDsought) internal view returns (string memory URI) {
        uint256 lowerLimit = 0;
        while (lowerLimit < _nextTokenId()) {
            if(lowerLimit <= _tokenIDsought && _tokenIDsought < uriMap[lowerLimit].upperLimit) return uriMap[lowerLimit].uri;
            lowerLimit = uriMap[lowerLimit].upperLimit;
        }     
    }

    // MUST only update existing entries
    function updateURI(uint256 _lowerLimit, string memory _newURI) public onlyRole(URI_ROLE) {
        if(bytes(uriMap[_lowerLimit].uri).length !=0) uriMap[_lowerLimit].uri = _newURI;
    }

    // MUST only update ONE 'tuple'
    function allocateAndSetURIs(uint256 quantity, string memory uri) public onlyRole(MINTER_ROLE) virtual {
        require(quantity>0);
        uriMap[_nextTokenId()] = uriHelper(_nextTokenId() + quantity,uri);
    }
}
