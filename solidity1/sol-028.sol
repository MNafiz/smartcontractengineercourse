// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Event {
    event Log(string message, uint256 val);
    // Up to 3 parameters can be indexed
    event IndexedLog(address indexed sender, uint256 val);
    event Message(address indexed from, address indexed to, string message);

    function examples() external {
        emit Log("Foo", 123);
        emit IndexedLog(msg.sender, 123);
    }
    
    function sendMessage(address addr, string calldata message) external {
        emit Message(msg.sender, addr, message);
    }
}