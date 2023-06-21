// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract ERC20Extended is IERC20, ERC1155Supply {
    // should we make a constant for the tokenID to be the 20? (potentially a DAO that splits into diff tokenIDs?)
    mapping(address => mapping(address => uint256)) private _allowances;
    constructor() {}

// events
// 
    function totalSupply() external view returns (uint256) {return totalSupply(0);}

    function balanceOf(address account) external view returns (uint256) {return ERC1155.balanceOf(account, 0);}

    function transfer(address to, uint256 amount) external returns (bool) {
    // should this have a false flag or is the revert in the call enough?
    // can/should we use the data attribute of the ERC1155?
        safeTransferFrom(msg.sender, to, 0, amount, '');
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        if (isApprovedForAll(owner, spender) == true) {
            return balanceOf(spender, 0);
        }
        else {
            return _allowances[owner][spender];
        }
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(_allowances[from][msg.sender] > amount, 'Insufficient Allowance');
        safeTransferFrom(from, to, 0, amount, '');
        return true;
    }
}
