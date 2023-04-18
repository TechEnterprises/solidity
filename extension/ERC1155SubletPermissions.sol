// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author TechEnterprises

import "./interface/IERC1155SubletPermissions.sol";
import "../../node_modules/@thirdweb-dev/contracts/lib/TWStrings.sol";

/**
 *  @title   ERC1155SubletPermissions
 *  @dev     This contracts provides extending-contracts with role-based access control mechanisms
 */
abstract contract ERC1155SubletPermissions is IERC1155SubletPermissions {
    /// @dev Map from keccak256 hash of a role => a map from address => whether address has role.
    mapping(uint256 => mapping(bytes32 => mapping(address => bool))) private _hasRole;

    /// @dev Map from keccak256 hash of a role to role admin. See {getRoleAdmin}.
    mapping(uint256 => mapping(bytes32 => bytes32)) private _getRoleAdmin;

    /// @dev Default admin role for all roles. Only accounts with this role can grant/revoke other roles.
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /// @dev Modifier that checks if an account has the specified role; reverts otherwise.
    modifier onlyRole(uint256 tokenId, bytes32 role) {
        _checkRole(tokenId, role, msg.sender);
        _;
    }

    /**
     *  @notice         Checks whether an account has a particular role.
     *  @dev            Returns `true` if `account` has been granted `role`.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account for which the role is being checked.
     */
    function hasRole(uint256 tokenId, bytes32 role, address account) public view returns (bool) {
        return _hasRole[tokenId][role][account];
    }

    /**
     *  @notice         Checks whether an account has a particular role;
     *                  role restrictions can be swtiched on and off.
     *
     *  @dev            Returns `true` if `account` has been granted `role`.
     *                  Role restrictions can be swtiched on and off:
     *                      - If address(0) has ROLE, then the ROLE restrictions
     *                        don't apply.
     *                      - If address(0) does not have ROLE, then the ROLE
     *                        restrictions will apply.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account for which the role is being checked.
     */
    function hasRoleWithSwitch(uint256 tokenId, bytes32 role, address account) public view returns (bool) {
        if (!_hasRole[tokenId][role][address(0)]) {
            return _hasRole[tokenId][role][account];
        }

        return true;
    }

    /**
     *  @notice         Returns the admin role that controls the specified role.
     *  @dev            See {grantRole} and {revokeRole}.
     *                  To change a role's admin, use {_setRoleAdmin}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     */
    function getRoleAdmin(uint256 tokenId, bytes32 role) external view returns (bytes32) {
        return _getRoleAdmin[tokenId][role];
    }

    /**
     *  @notice         Grants a role to an account, if not previously granted.
     *  @dev            Caller must have admin role for the `role`.
     *                  Emits {RoleGranted Event}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account to which the role is being granted.
     */
    function grantRole(uint256 tokenId, bytes32 role, address account) public virtual {
        _checkRole(tokenId, _getRoleAdmin[tokenId][role], msg.sender);
        if (_hasRole[tokenId][role][account]) {
            revert("Can only grant to non holders");
        }
        _setupRole(tokenId, role, account);
    }

    /**
     *  @notice         Revokes role from an account.
     *  @dev            Caller must have admin role for the `role`.
     *                  Emits {RoleRevoked Event}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account from which the role is being revoked.
     */
    function revokeRole(uint256 tokenId, bytes32 role, address account) public virtual {
        _checkRole(tokenId, _getRoleAdmin[tokenId][role], msg.sender);
        _revokeRole(tokenId, role, account);
    }

    /**
     *  @notice         Revokes role from the account.
     *  @dev            Caller must have the `role`, with caller being the same as `account`.
     *                  Emits {RoleRevoked Event}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account from which the role is being revoked.
     */
    function renounceRole(uint256 tokenId, bytes32 role, address account) public virtual {
        if (msg.sender != account) {
            revert("Can only renounce for self");
        }
        _revokeRole(tokenId, role, account);
    }

    /// @dev Sets `adminRole` as `role`'s admin role.
    function _setRoleAdmin(uint256 tokenId, bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = _getRoleAdmin[tokenId][role];
        _getRoleAdmin[tokenId][role] = adminRole;
        emit RoleAdminChanged(tokenId, role, previousAdminRole, adminRole);
    }

    /// @dev Sets up `role` for `account`
    function _setupRole(uint256 tokenId, bytes32 role, address account) internal virtual {
        _hasRole[tokenId][role][account] = true;
        emit RoleGranted(tokenId, role, account, msg.sender);
    }

    /// @dev Revokes `role` from `account`
    function _revokeRole(uint256 tokenId, bytes32 role, address account) internal virtual {
        _checkRole(tokenId, role, account);
        delete _hasRole[tokenId][role][account];
        emit RoleRevoked(tokenId, role, account, msg.sender);
    }

    /// @dev Checks `role` for `account`. Reverts with a message including the required role.
    function _checkRole(uint256 tokenId, bytes32 role, address account) internal view virtual {
        if (!_hasRole[tokenId][role][account]) {
            revert(
                string(
                    abi.encodePacked(
                        "TokenId: ",
                        TWStrings.toHexString(uint256(tokenId), 32),
                        "Permissions: account ",
                        TWStrings.toHexString(uint160(account), 20),
                        " is missing role ",
                        TWStrings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /// @dev Checks `role` for `account`. Reverts with a message including the required role.
    function _checkRoleWithSwitch(uint256 tokenId, bytes32 role, address account) internal view virtual {
        if (!hasRoleWithSwitch(tokenId, role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "TokenId: ",
                        TWStrings.toHexString(uint256(tokenId), 32),
                        "Permissions: account ",
                        TWStrings.toHexString(uint160(account), 20),
                        " is missing role ",
                        TWStrings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }
}
