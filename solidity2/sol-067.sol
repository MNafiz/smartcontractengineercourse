// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {DeployWithCreate2} from "sce/sol/DeployWithCreate2.sol";

contract Create2Factory {
    function deploy(uint256 salt) external returns (address) {
        // Write your code here
        DeployWithCreate2 con = new DeployWithCreate2{
            salt: bytes32(salt)
        }(msg.sender);
        return address(con);
    }
}