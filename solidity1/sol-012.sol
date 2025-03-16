// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract ForAndWhileLoops {
    function loop() external pure {
        // for loop
        for (uint256 i = 0; i < 10; i++) {
            if (i == 3) {
                // Skip to next iteration with continue
                continue;
            }
            if (i == 5) {
                // Exit loop with break
                break;
            }
        }

        // while loop
        uint256 j;
        while (j < 10) {
            j++;
        }
    }

    function sum(uint256 n) external pure returns (uint256) {
        // Write your code here
        uint256 result;
        for(uint256 i = 1; i <= n; i++) {
            result += i;
        }
        return result;
    }
}