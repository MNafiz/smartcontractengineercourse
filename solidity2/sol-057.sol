// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Zero {
    constructor(address _target) {
        // you can also write your code here
        // this might help
        _target.call("61");
    }
}

contract NoContractExploit {
    address public target;

    constructor(address _target) {
        target = _target;
    }

    function pwn() external {
        // write your code here
        new Zero(target);
    }
}