// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// gas golf
contract GasGolf {
    uint256 public total;

    function sumIfEvenAndLessThan99(uint256[] calldata nums) external {
        uint256 len = nums.length;
        uint256 _total;
        for (uint256 i = 0; i < len; i++) {
            uint256 num = nums[i];
            if ((num % 2 == 0) && (num < 99)) {
                _total += num;
            }
        }
        total = _total;
    }
}