// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./SubletControlUpgradeable.sol";

contract TokenSubletUpgradeable is SubletControlUpgradeable {

      // restricts Access to Administrators of a Token
    modifier onlyTokenAdmin(uint128 _tokenId) {
        _checkRole(getRole(_tokenId, "TOKEN_MANAGER"));
        _;
    }

    // restricts Access to Managers of a Token
    modifier onlyTokenManager(uint128 _tokenId) {
        _checkRole(getRole(_tokenId, "TOKEN_MANAGER"));
        _;
    }

    function setTOKEN_MANAGER(uint128 _tokenId, address _assignee) public onlyTokenAdmin(_tokenId) {
        _setupRole(getRole(_tokenId, "TOKEN_MANAGER"), _assignee);
    } 
    
    function setTOKEN_ADMIN(uint128 _tokenId, address _assignee) public onlyTokenAdmin(_tokenId) {
        _setupRole(getRole(_tokenId, "TOKEN_ADMIN"), _assignee);
    } 

    function transferAndRenounceTokenAdmin(uint128 _tokenId, address _newOwner) public onlyTokenAdmin(_tokenId) {
        _setupRole(getRole(_tokenId, "TOKEN_ADMIN"), _newOwner);
        renounceRole(getRole(_tokenId, "TOKEN_ADMIN"), msg.sender);
        // MUST trigger event (i think is does with renounceRole()
    }
}
