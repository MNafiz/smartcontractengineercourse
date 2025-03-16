// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

error DelegatecallFailed();

contract MultiDelegatecall {
    function multiDelegatecall(bytes[] calldata data)
        external
        payable
        returns (bytes[] memory results)
    {
        results = new bytes[](data.length);
        for(uint256 i ; i < data.length; i++) {
            (bool success, bytes memory response) = address(this).delegatecall(data[i]);
            if(!success) {
                revert DelegatecallFailed();
            }
            results[i] = response;
        }
        // code here
    }
}

contract TestMultiDelegatecall is MultiDelegatecall {
    event Log(address caller, string func, uint256 i);

    function func1(uint256 x, uint256 y) external {
        emit Log(msg.sender, "func1", x + y);
    }

    function func2() external returns (uint256) {
        emit Log(msg.sender, "func2", 2);
        return 111;
    }
}