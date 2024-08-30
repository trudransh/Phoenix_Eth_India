// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IndexCDP.sol";
import "./SP500CDP.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IndexCDPFactory is Ownable {
   event IndexCDPDeployed(address indexed cdpContract, string indexType);

   constructor(address initialOwner) Ownable(initialOwner) {
       transferOwnership(initialOwner);
   }

   // Function to deploy a generic IndexCDP contract
   function deployIndexCDP(
       address collateralToken,
       address phxToken,
       address uniswapV2Router,
       uint256 minimumCollateralAmount,
       uint256 liquidationThreshold
   ) external onlyOwner returns (address) {
       IndexCDP cdp = new IndexCDP(
           collateralToken,
           phxToken,
           uniswapV2Router,
           minimumCollateralAmount,
           liquidationThreshold
       );
       emit IndexCDPDeployed(address(cdp), "Generic");
       return address(cdp);
   }

   // Function to deploy a specific SP500CDP contract
   function deploySP500CDP(
       address collateralToken,
       address priceFeedAddress,
       address phxToken,
       address uniswapV2Router,
       uint256 minimumCollateralAmount,
       uint256 SP500CollateralizationRatio,
       uint256 SP500LiquidationThreshold,
       uint256 SP500StabilityFee
   ) external onlyOwner returns (address) {
       SP500CDP sp500Cdp = new SP500CDP(
           collateralToken,
           priceFeedAddress,
           phxToken,
           uniswapV2Router,
           minimumCollateralAmount,
           SP500CollateralizationRatio,
           SP500LiquidationThreshold,
           SP500StabilityFee
       );
       emit IndexCDPDeployed(address(sp500Cdp), "SP500");
       return address(sp500Cdp);
   }

   // Add more deployment functions for other specific types of Index CDPs if needed
   // ...

   // Any additional factory management functions can go here
   // ...
}