// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC721} from "sce/sol/IERC721.sol";

contract EnglishAuction {
    event Start();
    event Bid(address indexed sender, uint256 amount);
    event Withdraw(address indexed bidder, uint256 amount);
    event End(address winner, uint256 amount);

    IERC721 public immutable nft;
    uint256 public immutable nftId;

    address payable public immutable seller;
    uint256 public endAt;
    bool public started;
    bool public ended;

    address public highestBidder;
    uint256 public highestBid;
    // mapping from bidder to amount of ETH the bidder can withdraw
    mapping(address => uint256) public bids;

    constructor(address _nft, uint256 _nftId, uint256 _startingBid) {
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable(msg.sender);
        highestBid = _startingBid;
    }

    function start() external {
        // Write your code here
        require(msg.sender == seller, "not seller");
        require(!started, 'already started');
        nft.transferFrom(seller, address(this), nftId);
        started = true;
        endAt = block.timestamp + 7 days;
        
        emit Start();
    }

    function bid() external payable {
        // Write your code here
        uint256 msgValue = msg.value;
        require(started, 'not started');
        require(block.timestamp < endAt, "expired");
        require(msgValue > highestBid, "msg.value <= highestBid");
        
        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;   
        }
        highestBidder = msg.sender;
        highestBid = msgValue;
        
        emit Bid(msg.sender, msgValue);
    }

    function withdraw() external {
        // Write your code here
        uint256 amount = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        
        emit Withdraw(msg.sender, amount);
    }

    function end() external {
        // Write your code here
        require(started, "not started");
        require(!ended, "already ended");
        require(block.timestamp >= endAt, "not ended");
        
        ended = true;
        if (highestBidder != address(0)) {
            nft.transferFrom(address(this), highestBidder, nftId);
            payable(seller).transfer(highestBid);
        }
        else {
            nft.transferFrom(address(this), seller, nftId);
        }
        
        emit End(highestBidder, highestBid);
    }
}