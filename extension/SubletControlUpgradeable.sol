// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

// Provides helper utilities for creating per‑token roles by combining a token ID and a role string:
// function getRole(uint128 _brandId, string memory _role) internal pure returns (bytes32) {
//    bytes memory packed = abi.encodePacked(bytes16(_brandId), stringToBytes16(_role));
//    bytes32 result;
//    assembly { result := mload(add(packed, 32)) }
//    return result;
// }
 
abstract contract SubletControlUpgradeable is Initializable, AccessControlUpgradeable {

    // intended to allow the bytes32 _role of ACU to integrate the uint128 tokenId of a 721, 721A or 1155 contract

    function stringToBytes16(string memory str) internal pure returns (bytes16) {
        bytes memory strBytes = bytes(str);
        require(strBytes.length <= 16, "String is too long for bytes16");

        bytes16 result;
        assembly {
            mstore(result, mload(add(strBytes, 16)))
        }
        return result;
    }

    function getRole(uint128 _brandId, string memory _role) internal pure returns (bytes32) {
        bytes memory packed = abi.encodePacked(bytes16(_brandId), stringToBytes16(_role));
        bytes32 result;
        assembly { result := mload(add(packed, 32)) }
        return result;
    }

}
