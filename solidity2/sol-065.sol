// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract ReentrancyGuard {
    // Count stores number of times the function func was called
    uint256 public count;
    bool private lock = false;

    function exec(address target) external {
        require(!lock, "no reentrant");
        lock = true;
        (bool ok,) = target.call("");
        lock = false;
        require(ok, "call failed");
        count += 1;
    }
}