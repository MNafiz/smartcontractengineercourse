// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "sce/sol/IERC20.sol";
import {POOL, WETH, DAI} from "sce/aave-v3/Constants.sol";
import {IPool} from "sce/aave-v3/IPool.sol";
import {IVariableDebtToken} from "sce/aave-v3/IVariableDebtToken.sol";

contract AaveV3Liquidate {
    IERC20 private constant dai = IERC20(DAI);
    IPool private constant pool = IPool(POOL);
    IVariableDebtToken private immutable debtToken;

    constructor() {
        // Write your code here
        IPool.ReserveData memory reserve = pool.getReserveData(DAI);
        debtToken = IVariableDebtToken(reserve.variableDebtTokenAddress);
    }

    function liquidate(address user) external {
        // Write your code here
        (,,,,, uint256 healthFactor) = pool.getUserAccountData(user);
        require(healthFactor < 1e18, "health factor >= 1");
    
        uint256 debt = debtToken.balanceOf(user);
        dai.transferFrom(msg.sender, address(this), debt);
        dai.approve(address(pool), debt);
    
        pool.liquidationCall({
            collateralAsset: WETH,
            debtAsset: DAI,
            user: user,
            debtToCover: debt,
            receiveAToken: false
        });        
    }
}