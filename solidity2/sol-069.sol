// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Hodl {
    uint256 private constant HODL_DURATION = 3 * 365 days;

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public lockedUntil;

    function deposit() external payable {
        balanceOf[msg.sender] += msg.value;
        lockedUntil[msg.sender] = block.timestamp + HODL_DURATION;
    }

    function withdraw() external {
        require(block.timestamp >= lockedUntil[msg.sender] , "duration");
        uint256 amount = balanceOf[msg.sender];
        balanceOf[msg.sender] = 0;
        (bool sent,) = payable(msg.sender).call{value: amount}("");
        require(sent, "cannot transfer eth");
    }
}