// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "sce/sol/IERC20.sol";

contract CSAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(address _token0, address _token1) {
        // NOTE: This contract assumes that token0 and token1
        // both have same decimals
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function _mint(address to, uint256 amount) private {
        // Write code here
        balanceOf[to] += amount;
        totalSupply += amount;
    }

    function _burn(address from, uint256 amount) private {
        // Write code here
        balanceOf[from] -= amount;
        totalSupply -= amount;
    }

    function swap(address _tokenIn, uint256 _amountIn)
        external
        returns (uint256 amountOut)
    {
        // Write code here
        require(_tokenIn == address(token0) || _tokenIn == address(token1), "not whitelisted token");
        
        bool isToken0 = _tokenIn == address(token0);

        (IERC20 tokenIn, IERC20 tokenOut, uint256 resIn, uint256 resOut) = isToken0 ? (token0, token1, reserve0, reserve1) : (token1, token0, reserve1, reserve0);
        
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);
        
        amountOut = (_amountIn * 997) / 1000;

        (uint256 res0, uint256 res1) = isToken0
            ? (resIn + _amountIn, resOut - amountOut)
            : (resOut - amountOut, resIn + _amountIn);
    
        reserve0 = res0;
        reserve1 = res1;
    
        tokenOut.transfer(msg.sender, amountOut);

    }

    function addLiquidity(uint256 amount0, uint256 amount1)
        external
        returns (uint256 shares)
    {
        // Write code here
        token0.transferFrom(msg.sender, address(this), amount0);
        token1.transferFrom(msg.sender, address(this), amount1);
        
        uint256 bal0 = token0.balanceOf(address(this));
        uint256 bal1 = token1.balanceOf(address(this));
        
        if (totalSupply == 0) {
            shares = amount0 + amount1;
        }
        else {
            shares = ((amount0 + amount1) * totalSupply) / (reserve0 + reserve1);
        }
        
        require(shares > 0 , "shares = 0");
        _mint(msg.sender, shares);
        
        reserve0 = bal0;
        reserve1 = bal1;
    }

    function removeLiquidity(uint256 shares)
        external
        returns (uint256 d0, uint256 d1)
    {
        /*
        a = amount out
        L = total liquidity
        s = shares
        T = total supply
    
        a / L = s / T
    
        a = L * s / T
          = (reserve0 + reserve1) * s / T
        */
        d0 = (reserve0 * shares) / totalSupply;
        d1 = (reserve1 * shares) / totalSupply;
    
        _burn(msg.sender, shares);
    
        reserve0 = reserve0 - d0;
        reserve1 = reserve1 - d1;
    
        if (d0 > 0) {
            token0.transfer(msg.sender, d0);
        }
        if (d1 > 0) {
            token1.transfer(msg.sender, d1);
        }
    }
}