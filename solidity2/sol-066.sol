// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract MultiCall {
    function multiCall(address[] calldata targets, bytes[] calldata data)
        external
        view
        returns (bytes[] memory)
    {
        require(targets.length == data.length, "length is different");
        bytes[] memory results = new bytes[](data.length);
        
        for(uint256 i; i < data.length; i++) {
            (bool success, bytes memory response) = targets[i].staticcall(data[i]);
            require(success, "static call not success");
            results[i] = response;
        }

        return results;
    }
}