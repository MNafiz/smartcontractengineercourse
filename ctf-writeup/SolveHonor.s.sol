// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x87a0A8f3273C8E3410f79c3C55DAdE5cAFD75C50);
    address wallet = 0xB5b2Bc1a5026bF1d5Cca26B6269b537E42809A3a;
    Rivals public target = setup.TARGET();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0x824cac4d0d331d47371c275423cd6e4047ef8cc36d90346f7a0084c358242f5f);

        bytes32 key = 0xc1ca4e612d305a989d7d66b5dd6db923e9992902a44d46c1018546ff9aa062bf;
        target.talk(key);
        console.log(setup.isSolved(wallet));

        vm.stopBroadcast();
    }
}

// "PrivateKey": "0x824cac4d0d331d47371c275423cd6e4047ef8cc36d90346f7a0084c358242f5f",
//     "Address": "0xB5b2Bc1a5026bF1d5Cca26B6269b537E42809A3a",
//     "TargetAddress": "0x1bDf4D240CCd4BFbc0Abc7b248a83F7Cdc294202",
//     "setupAddress": "0x87a0A8f3273C8E3410f79c3C55DAdE5cAFD75C50"

contract Setup {
    Rivals public immutable TARGET;

    constructor(bytes32 _encryptedFlag, bytes32 _hashed) payable {
        TARGET = new Rivals(_encryptedFlag, _hashed);
    }

    function isSolved(address _player) public view returns (bool) {
        return TARGET.solver() == _player;
    }
}

contract Rivals {
    event Voice(uint256 indexed severity);

    bytes32 private encryptedFlag;
    bytes32 private hashedFlag;
    address public solver;

    constructor(bytes32 _encrypted, bytes32 _hashed) {
        encryptedFlag = _encrypted;
        hashedFlag = _hashed;
    }

    function talk(bytes32 _key) external {
        bytes32 _flag = _key ^ encryptedFlag;
        if (keccak256(abi.encode(_flag)) == hashedFlag) {
            solver = msg.sender;
            emit Voice(5);
        } else {
            emit Voice(block.timestamp % 5);
        }
    }
}