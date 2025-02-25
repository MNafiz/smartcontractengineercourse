// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "sce/sol/IERC20.sol";
import {POOL, DAI} from "sce/aave-v3/Constants.sol";
import {IPool} from "sce/aave-v3/IPool.sol";

contract AaveV3Supply {
    IERC20 private constant dai = IERC20(DAI);
    IPool private constant pool = IPool(POOL);

    function supply(uint256 amount) external {
        // Write your code here
        dai.transferFrom(msg.sender, address(this), amount);
        dai.approve(address(pool), amount);
        pool.supply(address(dai), amount, address(this), 0);
    }
}