// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "sce/sol/IERC20.sol";
import {POOL, DAI, WETH} from "sce/aave-v3/Constants.sol";
import {IPool} from "sce/aave-v3/IPool.sol";

contract AaveV3Borrow {
    IPool private constant pool = IPool(POOL);
    IERC20 private constant weth = IERC20(WETH);
    IERC20 private constant dai = IERC20(DAI);

    function borrow() external {
        // Write your code here
        weth.approve(address(pool), 1e18);
        pool.supply(WETH, 1e18, address(this), 0);
        
        (,,uint256 availableToBorrowUsd,,,) = pool.getUserAccountData(address(this));
        
        uint256 amount = availableToBorrowUsd * 1e10 * 99 / 100;
        
        pool.borrow(DAI, amount, 2, 0, address(this));
    }
}