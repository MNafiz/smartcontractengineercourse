// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {TestContract} from "sce/sol/TestContract.sol";

contract CallTestContract {
    function setX(TestContract test, uint256 x) external {
        test.setX(x);
    }

    function setXfromAddress(address addr, uint256 x) external {
        TestContract test = TestContract(addr);
        test.setX(x);
    }

    function getX(address addr) external view returns (uint256) {
        uint256 x = TestContract(addr).getX();
        return x;
    }

    function setXandSendEther(TestContract test, uint256 x) external payable {
        test.setXandReceiveEther{value: msg.value}(x);
    }

    function getXandValue(address addr)
        external
        view
        returns (uint256, uint256)
    {
        (uint256 x, uint256 value) = TestContract(addr).getXandValue();
        return (x, value);
    }

    function setXwithEther(address addr) external payable {
        TestContract(addr).setXtoValue{value: msg.value}();
    }

    function getValue(address addr) external view returns (uint256) {
        uint256 value = TestContract(addr).getValue();
        return value;
    }
}