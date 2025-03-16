// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract DelegateCall {
    uint256 public num;
    address public sender;
    uint256 public value;

    function setVars(address test, uint256 _num) external payable {
        // This contract's storage is updated, TestDelegateCall's storage is not modified.
        (bool success, bytes memory data) =
            test.delegatecall(abi.encodeWithSignature("setVars(uint256)", _num));
        require(success, "tx failed");
    }

    function setNum(address test, uint256 _num) external {
        // Write your code here
        (bool success, bytes memory data) =
            test.delegatecall(abi.encodeWithSignature("setNum(uint256)", _num));
        require(success, "tx failed");
    }
}