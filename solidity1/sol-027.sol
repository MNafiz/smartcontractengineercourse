// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract ArrayReplaceLast {
    uint256[] public arr = [1, 2, 3, 4];

    function remove(uint256 index) external {
        // Write your code here
        arr[index] = arr[arr.length - 1];
        arr.pop();
    }
}