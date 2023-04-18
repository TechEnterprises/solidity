// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../../node_modules/@thirdweb-dev/contracts/base/ERC1155Drop.sol";
import "../../node_modules/@thirdweb-dev/contracts/extension/Upgradeable.sol";
import "../../node_modules/@thirdweb-dev/contracts/extension/Initializable.sol";


abstract contract UpgradeableERC1155 is Upgradeable, Initializable, 
ERC1155Drop {
    address public deployer;
	constructor() initializer {}

	function initialize() external initializer {deployer = msg.sender;}

	function _authorizeUpgrade(address) internal view override {
		require(msg.sender == deployer);
	}
}