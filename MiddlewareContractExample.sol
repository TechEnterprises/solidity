//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract Emitter{
    using SafeMath for uint256;
    IERC20 public usdcToken;
    bool public Stop;

    constructor(address _usdcTokenAddress) {
        usdcToken = IERC20(_usdcTokenAddress);
    }


    function allow(uint256 amount) public {
        IERC20(usdcToken).approve(msg.sender, amount);
    }
    function SendToContract(uint256 amount)  external {
        IERC20(usdcToken).transferFrom(msg.sender, address(this), amount); // Transfer USD to contract
    }
    function contractBalance() public view returns( uint256) {
        uint256 contract_usdc_balance=IERC20(usdcToken).balanceOf(address(this));
        return contract_usdc_balance;
    }
    function HowMuchCanISend() public view returns(uint256){
            uint256 howmuch=IERC20(usdcToken).allowance(address(this),msg.sender);
            return howmuch;
        }
    }
