// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "sce/sol/IERC20.sol";

contract Vault {
    IERC20 public immutable token;
    
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function _mint(address to, uint256 shares) private {
        // code here
        balanceOf[to] += shares;
        totalSupply += shares;
    }

    function _burn(address from, uint256 shares) private {
        // code here
        balanceOf[from] -= shares;
        totalSupply -= shares;
    }

    function deposit(uint256 amount) external {
        // code here
        uint256 balanceTokenThis = token.balanceOf(address(this));
        
        uint256 shares;
        if (totalSupply == 0) {
            shares = amount;
        }
        // (L + a) / L = (token(address(this)) + amount) / token(address(this))
        // a = ((btt + amount) * L) / btt  - L
        // a = (amount * L) / btt
        else {
            shares = (amount * totalSupply) / balanceTokenThis; 
        }
        token.transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, shares);
    }

    function withdraw(uint256 shares) external {
        // code here
        uint256 balanceTokenThis = token.balanceOf(address(this));
        uint256 amount = (shares * balanceTokenThis) / totalSupply;
        token.transfer(msg.sender, amount);
        _burn(msg.sender, shares);
    }
}