// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "sce/sol/IERC20.sol";
import {POOL, WETH} from "sce/aave-v3/Constants.sol";
import {IPool} from "sce/aave-v3/IPool.sol";

contract AaveV3Withdraw {
    IERC20 private constant weth = IERC20(WETH);
    IPool private constant pool = IPool(POOL);
    IERC20 private immutable aToken;

    constructor() {
        // Write your code here
        IPool.ReserveData memory reserve = pool.getReserveData(WETH);
        aToken = IERC20(reserve.aTokenAddress);
    }

    function withdraw() external {
        // Write your code here
        pool.withdraw({
            asset: WETH,
            amount: aToken.balanceOf(address(this)),
            to: address(this)
        });
    }
}