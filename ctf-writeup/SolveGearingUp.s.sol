// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0xDba65F8883B01414D6A4a9e5AaeA5F543ea5ffFD);
    address wallet = 0x4AE8862ec7676FdA966A3e4E4dE233f7c31B4e0D;
    GearingUp public GU = setup.GU();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0xf76a2259c4851266809d4c301e342ea35cb54aaf6958f3daf6ad72e57edcfd7f);

        console.log(wallet.balance);

        Hack hack = new Hack(address(GU));
        hack.solve{value: 5 ether}();

        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

// UUID	b296772b-539b-4005-af47-6ec05f3962f7
// RPC Endpoint	http://103.178.153.113:30002/b296772b-539b-4005-af47-6ec05f3962f7
// Private Key	0xf76a2259c4851266809d4c301e342ea35cb54aaf6958f3daf6ad72e57edcfd7f
// Setup Contract	0xDba65F8883B01414D6A4a9e5AaeA5F543ea5ffFD
// Wallet	0x4AE8862ec7676FdA966A3e4E4dE233f7c31B4e0D

contract Hack {
    GearingUp public GU;

    constructor(address _chall) {
        GU = GearingUp(_chall);
    }

    function solve() external payable {
        GU.callThis();
        GU.sendMoneyHere{value: 5 ether}();
        GU.withdrawReward();

        string memory password = "GearNumber1";
        uint256 code = 687221;
        bytes4 fourBytes = bytes4(0x1a2b3c4d);
        address sender = address(this);

        GU.sendSomeData(password, code, fourBytes, sender);
        GU.completedGearingUp();

    }

    receive() external payable {}
}

contract Setup {
    GearingUp public GU;

    constructor() payable{
        GU = new GearingUp{value: 10 ether}();
    }

    function isSolved() public view returns(bool){
        return GU.allFinished();
    }

}


contract GearingUp{

    bool public callOne;
    bool public depositOne;
    bool public withdrawOne;
    bool public sendData;
    bool public allFinished;

    constructor() payable{
        require(msg.value == 10 ether);
    }

    function callThis() public{
        // verify that a smart contract is calling this.
        require(msg.sender != tx.origin);
        callOne = true;
    }

    function sendMoneyHere() public payable{
        require(msg.sender != tx.origin);
        require(msg.value == 5 ether);
        depositOne = true;
    }

    function withdrawReward() public{
        require(msg.sender != tx.origin);
        (bool transfered, ) = msg.sender.call{value: 5 ether}("");
        require(transfered, "Failed to Send Reward!");
        withdrawOne = true;
    }

    function sendSomeData(string memory password, uint256 code, bytes4 fourBytes, address sender) public{
        if(
            keccak256(abi.encodePacked(password)) == keccak256(abi.encodePacked("GearNumber1")) &&
            code == 687221 &&
            keccak256(abi.encodePacked(fourBytes)) == keccak256(abi.encodePacked(bytes4(0x1a2b3c4d))) &&
            sender == msg.sender
        ){
            sendData = true;
        }
    }

    function completedGearingUp() public{
        if(
            callOne == true &&
            depositOne == true &&
            withdrawOne == true &&
            sendData == true
        ){
            allFinished = true;
        }
    }

}