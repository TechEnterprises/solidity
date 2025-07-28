// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

///////////////////////////
// Implements an ERC20 interface on top of ERC1155Supply, using token ID 0 as the ERC‑20 representation.
// totalSupply, balanceOf, and transfers all map to token ID 0.
// Example lines showing this mapping:
// ------------------------------------------------
// function totalSupply() external view returns (uint256) { return totalSupply(0); }
// function balanceOf(address account) external view returns (uint256) { return ERC1155.balanceOf(account, 0); }
// function transfer(address to, uint256 amount) external returns (bool) {
//     safeTransferFrom(msg.sender, to, 0, amount, '');
//     emit Transfer(msg.sender, to, amount);
//     return true;
/ }
/////////////////////////////

abstract contract ERC20Extended is IERC20, ERC1155Supply {
    // should we make a constant for the tokenID to be the 20? (potentially a DAO that splits into diff tokenIDs?)
    mapping(address => mapping(address => uint256)) private _allowances;
    // make this a struct and we could make every tokenId act like a 20, perhaps for DAOs or DEX shares
    string public name;
    string public symbol;
    uint256 public initialSupply;
    
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
