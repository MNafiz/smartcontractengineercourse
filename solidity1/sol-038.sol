// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract EtherWallet {
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }
    function withdraw(uint256 amount) external {
        require(owner == msg.sender, 'not owner');
        (bool sent,) = msg.sender.call{value: amount}("");
        require(sent, "failed to send Ether");
    }
    receive() external payable {}
}