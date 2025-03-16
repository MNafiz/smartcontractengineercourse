// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC721} from "sce/sol/IERC721.sol";

contract DutchAuction {
    uint256 private constant DURATION = 7 days;

    IERC721 public immutable nft;
    uint256 public immutable nftId;

    address payable public immutable seller;
    uint256 public immutable startingPrice;
    uint256 public immutable startAt;
    uint256 public immutable expiresAt;
    uint256 public immutable discountRate;

    constructor(
        uint256 _startingPrice,
        uint256 _discountRate,
        address _nft,
        uint256 _nftId
    ) {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        startAt = block.timestamp;
        expiresAt = block.timestamp + DURATION;
        discountRate = _discountRate;

        require(
            _startingPrice >= _discountRate * DURATION, "starting price < min"
        );

        nft = IERC721(_nft);
        nftId = _nftId;
    }

    function getPrice() public view returns (uint256) {
        // Code here
        return startingPrice - (discountRate * (block.timestamp - startAt));
    }

    function buy() external payable {
        // Code here
        uint256 currentPrice = getPrice();
        require(block.timestamp < expiresAt, "expired");
        require(msg.value >= currentPrice, "msg.value < getPrice()");
        nft.transferFrom(seller, msg.sender, nftId);
        (bool ok,) = msg.sender.call{value: msg.value - currentPrice}("");
        require(ok);
        (ok,) = seller.call{value: currentPrice}("");
        require(ok);
        
    }
}