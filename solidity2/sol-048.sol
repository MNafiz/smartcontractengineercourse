// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Kill {
    constructor() payable {}

    function kill() external {
        // Write your code here
        selfdestruct(payable(msg.sender));
    }
}