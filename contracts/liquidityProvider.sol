// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IndexCDP.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract LiquidityProvider {
 IndexCDP public cdpContract;
 IERC20 public usdcToken;
 IERC20 public phxToken;
 IUniswapV2Router02 public uniswapRouter;

 constructor(
    address _cdpContract,
    address _usdcToken,
    address _phxToken,
    address _uniswapRouter
 ) {
    cdpContract = IndexCDP(_cdpContract);
    usdcToken = IERC20(_usdcToken);
    phxToken = IERC20(_phxToken);
    uniswapRouter = IUniswapV2Router02(_uniswapRouter);
 }

 function depositUSDC(uint256 amount) external {
    // Transfer USDC from the user to this contract
    usdcToken.transferFrom(msg.sender, address(this), amount);
 }

 function mintPHX(uint256 amount) external {
    // Mint the specified amount of PHX tokens
    phxToken.mint(address(this), amount);
 }

 function burnPHX(uint256 amount) external {
    // Burn the specified amount of PHX tokens
    phxToken.burn(amount);
 }

 function addLiquidity(uint256 usdcAmount, uint256 phxAmount) external {
    // Transfer USDC and PHX from this contract to the CDP contract
    usdcToken.transfer(address(cdpContract), usdcAmount);
    phxToken.transfer(address(cdpContract), phxAmount);

    // Approve the Uniswap Router to spend the tokens
    usdcToken.approve(address(uniswapRouter), usdcAmount);
    phxToken.approve(address(uniswapRouter), phxAmount);

    // Add liquidity to Uniswap V2
    uniswapRouter.addLiquidity(
        address(usdcToken),
        address(phxToken),
        usdcAmount,
        phxAmount, 
        0, // Minimum USDC amount
        0, // Minimum PHX amount
        msg.sender, // Recipient of the liquidity tokens
        block.timestamp + 15 // Deadline
    );
 }
}
