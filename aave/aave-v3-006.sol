// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "sce/sol/IERC20.sol";
import {DAI, POOL} from "sce/aave-v3/Constants.sol";
import {IPool} from "sce/aave-v3/IPool.sol";

contract AaveV3FlashLoan {
    IPool private constant pool = IPool(POOL);
    IERC20 private constant dai = IERC20(DAI);

    function startFlashLoan() external {
        // Write your code here
        pool.flashLoanSimple({
            receiverAddress: address(this),
            asset: DAI,
            amount: 1e6 * 1e18,
            params: abi.encode(msg.sender),
            referralCode: 0
        });
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 fee,
        address initiator,
        bytes calldata params
    ) external returns (bool) {
        // Write your code here
        require(msg.sender == POOL, "not pool");
        require(initiator == address(this), "not initiator");
        
        address caller = abi.decode(params, (address));
        dai.transferFrom(caller, address(this), fee);
        dai.approve(msg.sender, amount + fee);
        
        return true;
    }
}