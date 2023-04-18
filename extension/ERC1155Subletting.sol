// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;
import "./ERC1155BrandManagement.sol";
import "./interface/IERC1155Subletting.sol";
import "./ERC1155SubletPermissions.sol";

/// @author TechEnterprises

/**
 *  @title   ERC1155BrandManagement
 *  @dev     This contracts provides extending-contracts with role-based access control 
 *           mechanisms BY THE TOKEN_ID! This allows subletting of the contract to third-parties.
 *           Also provides interfaces to view all members with a given role, and total count of members.
 */
abstract contract ERC1155Subletting is IERC1155Subletting, ERC1155SubletPermissions {
    /**
     *  @notice A data structure to store data of members for a given role.
     *
     *  @param index    Current index in the list of accounts that have a role.
     *  @param members  map from index => address of account that has a role
     *  @param indexOf  map from address => index which the account has.
     */
    struct RoleMembers {
        uint256 index;
        mapping(uint256 => address) members;
        mapping(address => uint256) indexOf;
    }

    /// @dev map from keccak256 hash of a role to its members' data. See {RoleMembers}.
    mapping(uint256 => mapping(bytes32 => RoleMembers)) private roleMembers;

    /**
     *  @notice         Returns the role-member from a list of members for a role,
     *                  at a given index.
     *  @dev            Returns `member` who has `role`, at `index` of role-members list.
     *                  See struct {RoleMembers}, and mapping {roleMembers}
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param index    Index in list of current members for the role.
     *
     *  @return member  Address of account that has `role`
     */
    function getRoleMember(uint256 tokenId, bytes32 role, uint256 index) external view returns (address member) {
        uint256 currentIndex = roleMembers[tokenId][role].index;
        uint256 check;

        for (uint256 i = 0; i < currentIndex; i += 1) {
            if (roleMembers[tokenId][role].members[i] != address(0)) {
                if (check == index) {
                    member = roleMembers[tokenId][role].members[i];
                    return member;
                }
                check += 1;
            } else if (hasRole(tokenId, role, address(0)) && i == roleMembers[tokenId][role].indexOf[address(0)]) {
                check += 1;
            }
        }
    }

    /**
     *  @notice         Returns total number of accounts that have a role.
     *  @dev            Returns `count` of accounts that have `role`.
     *                  See struct {RoleMembers}, and mapping {roleMembers}
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *
     *  @return count   Total number of accounts that have `role`
     */
    function getRoleMemberCount(uint256 tokenId, bytes32 role) external view returns (uint256 count) {
        uint256 currentIndex = roleMembers[tokenId][role].index;

        for (uint256 i = 0; i < currentIndex; i += 1) {
            if (roleMembers[tokenId][role].members[i] != address(0)) {
                count += 1;
            }
        }
        if (hasRole(tokenId, role, address(0))) {
            count += 1;
        }
    }

    /// @dev Revokes `role` from `account`, and removes `account` from {roleMembers}
    ///      See {_removeMember}
    function _revokeRole(uint256 tokenId, bytes32 role, address account) internal override {
        super._revokeRole(tokenId, role, account);
        _removeMember(tokenId, role, account);
    }

    /// @dev Grants `role` to `account`, and adds `account` to {roleMembers}
    ///      See {_addMember}
    function _setupRole(uint256 tokenId, bytes32 role, address account) internal override {
        super._setupRole(tokenId, role, account);
        _addMember(tokenId, role, account);
    }

    /// @dev adds `account` to {roleMembers}, for `role`
    function _addMember(uint256 tokenId, bytes32 role, address account) internal {
        uint256 idx = roleMembers[tokenId][role].index;
        roleMembers[tokenId][role].index += 1;

        roleMembers[tokenId][role].members[idx] = account;
        roleMembers[tokenId][role].indexOf[account] = idx;
    }

    /// @dev removes `account` from {roleMembers}, for `role`
    function _removeMember(uint256 tokenId, bytes32 role, address account) internal {
        uint256 idx = roleMembers[tokenId][role].indexOf[account];

        delete roleMembers[tokenId][role].members[idx];
        delete roleMembers[tokenId][role].indexOf[account];
    }
}
