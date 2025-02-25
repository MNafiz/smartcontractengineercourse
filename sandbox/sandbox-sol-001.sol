// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console2 as console} from "forge-std/Test.sol";

contract Sandbox is Test {
    function testSomething() external payable {
        console.log("Log something", address(this).balance);
        assertEq(uint256(1), uint256(1));
    }
}