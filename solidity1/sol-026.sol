// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract ArrayShift {
    uint256[] public arr = [1, 2, 3, 4, 5];

    function remove(uint256 index) external {
        // Write your code here
        require(index < arr.length, "index out of bound");
        for(uint256 i = index; i < arr.length - 1; i++) {
            arr[i] = arr[i + 1];
        }
        arr.pop();
    }
}