// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IndexCDP.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract LiquidityProvider {
    IndexCDP public indexCDP;
    IERC20 public usdcToken;
    IERC20 public phxToken;
    IUniswapV2Router02 public uniswapRouter;

    constructor(
        address _indexCDPAddress,
        address _usdcTokenAddress,
        address _phxTokenAddress,
        address _uniswapRouterAddress
    ) {
        indexCDP = IndexCDP(_indexCDPAddress);
        usdcToken = IERC20(_usdcTokenAddress);
        phxToken = IERC20(_phxTokenAddress);
        uniswapRouter = IUniswapV2Router02(_uniswapRouterAddress);
    }

    function depositUSDCAndMintPHX(uint256 usdcAmount) external {
        require(usdcToken.transferFrom(msg.sender, address(this), usdcAmount), "USDC transfer failed");

        // Interact with the IndexCDP to deposit collateral and mint PHX tokens
        indexCDP.createCDP(usdcAmount); // This assumes the createCDP function is adjusted to mint PHX tokens

        // Add liquidity to Uniswap
        addLiquidity(usdcAmount, usdcAmount); // Assumes 1 USDC = 1 PHX for simplicity
    }

    function addLiquidity(uint256 usdcAmount, uint256 phxAmount) public {
        // Approve Uniswap to spend tokens
        require(usdcToken.approve(address(uniswapRouter), usdcAmount), "USDC approval failed");
        require(phxToken.approve(address(uniswapRouter), phxAmount), "PHX approval failed");

        // Add liquidity to Uniswap
        uniswapRouter.addLiquidity(
            address(usdcToken),
            address(phxToken),
            usdcAmount,
            phxAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            msg.sender, // recipient of liquidity tokens
            block.timestamp // deadline
        );
    }

    // Other functions such as withdrawing liquidity can be added as required.
}