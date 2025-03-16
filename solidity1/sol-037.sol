// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract SendEther {
    function sendViaTransfer(address payable to) external payable {
        // This function is no longer recommended for sending Ether.
        to.transfer(msg.value);
    }

    function sendViaSend(address payable to) external payable {
        // Send returns a boolean value indicating success or failure.
        // This function is not recommended for sending Ether.
        bool sent = to.send(msg.value);
        require(sent, "Failed to send Ether");
    }

    function sendViaCall(address payable to) external payable {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, bytes memory data) = to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
    
    function sendEth(address payable to, uint256 amount) external {
        (bool sent,) = to.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
    
    receive() external payable {}
}