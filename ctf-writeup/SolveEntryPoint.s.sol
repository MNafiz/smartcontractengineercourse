// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x72317787434E1823d1B52169f27EB8de386005cb);
    address wallet = 0xCaCEE95f9bf47D073e3a869c277b7Ab7a0AD6191;
    EntryPoint public EP = setup.EP();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0xffdfcaaeaba9e54896a161e683634fb1d04f92d9f25873d7e21ef6ae5ca9ade5);

        EP.getCoin{value: 7157}();

        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

// UUID	a12332a3-1737-4c94-8fb1-a3c5da31c2de
// RPC Endpoint	http://103.178.153.113:40002/a12332a3-1737-4c94-8fb1-a3c5da31c2de
// Private Key	0xffdfcaaeaba9e54896a161e683634fb1d04f92d9f25873d7e21ef6ae5ca9ade5
// Setup Contract	0x72317787434E1823d1B52169f27EB8de386005cb
// Wallet	0xCaCEE95f9bf47D073e3a869c277b7Ab7a0AD6191

contract Setup{
    EntryPoint public EP;

    constructor() {
        EP = new EntryPoint();
    }

    function isSolved() public view returns(bool){
        return EP.entered();
    }

}
contract EntryPoint{

    uint256 public constant TOKENS_PER_ETHER = 0.1910191 ether;
    bool public entered;
    mapping(address => uint256) public ownedCoin;

    // The Casino is not open for everyone, only those who have at least a coin can enter.
    function getCoin() public payable{
        require(msg.value > 0, "Must send ether to receive tokens");
        require(msg.value > 7000 wei && msg.value < 8000, "7 is not a lucky number here");
        uint256 coins = (msg.value * TOKENS_PER_ETHER) / 1 ether;
        if(coins == 1367){
            ownedCoin[msg.sender] += coins;
            entered = true;
        }
    }

    receive() external payable{}

} 