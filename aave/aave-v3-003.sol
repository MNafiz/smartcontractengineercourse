// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "sce/sol/IERC20.sol";
import {POOL, DAI} from "sce/aave-v3/Constants.sol";
import {IPool} from "sce/aave-v3/IPool.sol";
import {IVariableDebtToken} from "sce/aave-v3/IVariableDebtToken.sol";

contract AaveV3Repay {
    IERC20 private constant dai = IERC20(DAI);
    IPool private constant pool = IPool(POOL);
    IVariableDebtToken private immutable debtToken;

    constructor() {
        // Write your code here
        IPool.ReserveData memory reserve = pool.getReserveData(DAI);
        debtToken = IVariableDebtToken(reserve.variableDebtTokenAddress);
        debtToken.approveDelegation(msg.sender, type(uint256).max);
    }

    function repay() external {
        // Write your code here
        uint256 debt = debtToken.balanceOf(address(this));
    
        dai.transferFrom(msg.sender, address(this), debt);
        dai.approve(address(pool), debt);
    
        pool.repay({
            asset: DAI,
            amount: debt,
            interestRateMode: 2,
            onBehalfOf: address(this)
        }); 
    }
}