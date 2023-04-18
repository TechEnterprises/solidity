// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./base/UpgradeableERC1155.sol";
import "./extension/ERC1155BrandManagement.sol";
// import "./extension/interface/IERC1155BrandManagement.sol";
import "../node_modules/@thirdweb-dev/contracts/extension/PlatformFee.sol";
//import "../node_modules/@thirdweb-dev/contracts/extension/Permissions.sol";
//import "../node_modules/@thirdweb-dev/contracts/extension/interface/IPermissions.sol";
import "./extension/ERC1155Subletting.sol";

contract TestT3Dv0_0_0016 is
    UpgradeableERC1155,
    ERC1155Subletting,
    ERC1155BrandManagement
{
    constructor() initializer {}

    function initialize() public override {
        __ERC1155Drop_Init("Hell Yah! Token", "HYA", msg.sender, 130, msg.sender);
        __PlatformFee_Init(130);
        
    }
}