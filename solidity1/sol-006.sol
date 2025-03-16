// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract GlobalVariables {
    function globalVars() external {
        // Address that called this function
        address sender = msg.sender;
        // Timestamp (in seconds) of current block
        uint256 timeStamp = block.timestamp;
        // Current block number
        uint256 blockNum = block.number;
        // Hash of given block
        // This gets the hash of the current block
        // WARNING: only works for 256 recent blocks
        bytes32 blockHash = blockhash(block.number);
    }
    
    function returnSender() external view returns (address) {
        return msg.sender;
    }
}