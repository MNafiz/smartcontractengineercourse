// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Counter {
// Write your code here
    uint256 public count;
    
    function inc() external {
        count++;
    }
    
    function dec() external {
        count--;
    }
}