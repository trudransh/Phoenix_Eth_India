// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IIndexCDP.sol";
import "./libraries/CDPHelper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "contracts/PHXtoken.sol";

contract IndexCDP is ReentrancyGuard, AccessControl {
   IERC20 public collateralToken;
   IERC20 public phxToken;
   IUniswapV2Router02 public uniswapV2Router;

   // Define a role for managing the CDP
   bytes32 public constant CDP_MANAGER_ROLE = keccak256("CDP_MANAGER_ROLE");
   // Define a role for minting tokens
   bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

   struct CDP {
       uint256 collateralAmount;
       uint256 debtAmount;
       uint256 lastInteractionTime;
   }

   mapping(address => CDP) public cdps;

   uint256 public minimumCollateralAmount; // Define a minimum collateral amount
   uint256 public liquidationThreshold; // The threshold at which a CDP is subject to liquidation

   constructor(
       address _collateralToken,
       address _phxToken,
       address _uniswapV2Router,
       uint256 _minimumCollateralAmount,
       uint256 _liquidationThreshold
   ) {
       collateralToken = IERC20(_collateralToken);
       phxToken = IERC20(_phxToken);
       uniswapV2Router = IUniswapV2Router02(_uniswapV2Router);
       minimumCollateralAmount = _minimumCollateralAmount;
       liquidationThreshold = _liquidationThreshold;

       // Setup CDP manager role
       grantRole(CDP_MANAGER_ROLE, msg.sender);
   }

   function createCDP(uint256 collateralAmount)
       external
       nonReentrant
       onlyRole(CDP_MANAGER_ROLE)
       virtual // Add the 'virtual' keyword here
   {
       require(
           collateralAmount >= minimumCollateralAmount,
           "Collateral is too low"
       );

       collateralToken.transferFrom(
           msg.sender,
           address(this),
           collateralAmount
       );

       uint256 debtAmount = calculateDebtAmount(collateralAmount);
       cdps[msg.sender] = CDP(collateralAmount, debtAmount, block.timestamp);

       // Mint PHX tokens equivalent to the collateral amount
       PHXToken phxTokenInstance = PHXToken(address(phxToken));
       phxTokenInstance.mint(msg.sender, collateralAmount);
   }

   // Additional functions like addCollateral, removeCollateral, borrowDebt, repayDebt

   function calculateDebtAmount(uint256 collateralAmount)
       internal
       view
       returns (uint256)
   {
       // Implement debt calculation logic
       return collateralAmount * 2; // Example logic
   }

   function swapPHXForUSDC(uint256 phxAmount) external {
       // Approve the Uniswap V2 router to spend the PHX tokens
       phxToken.approve(address(uniswapV2Router), phxAmount);

       // Execute the swap on the Uniswap V2 router
       uniswapV2Router.swapExactTokensForTokens(
           phxAmount, // Input amount
           0, // Minimum output amount
           getPathForPHXToUSDC(), // Path
           msg.sender, // Recipient
           block.timestamp + 15 // Deadline
       );
   }

   function getPathForPHXToUSDC() private view returns (address[] memory) {
       address[] memory path = new address[](2);
       path[0] = address(phxToken);
       path[1] = uniswapV2Router.WETH();

       return path;
   }

   function liquidateCDP(address cdpOwner)
       external
       nonReentrant
       onlyRole(CDP_MANAGER_ROLE)
   {
       require(
           isSubjectToLiquidation(cdpOwner),
           "CDP is not subject to liquidation"
       );

       // Implement liquidation logic
       // ...
   }

   function isSubjectToLiquidation(address cdpOwner)
       public
       view
       returns (bool)
   {
       CDP memory cdp = cdps[cdpOwner];
       // Implement liquidation check
       return cdp.collateralAmount * liquidationThreshold < cdp.debtAmount;
   }
}
