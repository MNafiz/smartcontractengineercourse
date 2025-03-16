// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract ErrorHandling {
    function exampleRequire(uint256 i) external pure {
        // Require should be used to validate conditions such as:
        // - inputs
        // - conditions before execution
        // - return values from calls to other functions
        require(i <= 10, "i > 10");
    }

    function exampleRevert(uint256 i) external pure {
        // Revert is useful when the condition to check is complex.
        // This code does the exact same thing as the example above
        if (i > 10) {
            revert("i > 10");
        }
    }

    uint256 num;

    function exampleAssert() external view {
        // Assert should only be used to test for internal errors,
        // and to check invariants.

        // Assert that num is always equal to 0
        assert(num == 0);
    }

    function div(uint256 x, uint256 y) external pure returns (uint256) {
        // Write your code here
        require(y > 0, "div by 0");
        return x / y;
    }
}