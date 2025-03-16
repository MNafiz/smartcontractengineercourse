// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract HashFunc {
    function hash(string memory text, uint256 num, address addr)
        external
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(text, num, addr));
    }

    function getHash(address addr, uint256 num)
        external
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(addr, num));
    }
}