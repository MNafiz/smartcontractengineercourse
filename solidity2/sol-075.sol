// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20} from "sce/sol/ERC20.sol";

contract WETH is ERC20 {
    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);

    constructor() ERC20("Wrapped Ether", "WETH", 18) {}
    
    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        _burn(msg.sender, amount);
        (bool sent,) = msg.sender.call{value: amount}("");
        require(sent, "send eth failed");
        emit Withdraw(msg.sender, amount);
    }
    
    receive() external payable {
        deposit();
    }
}