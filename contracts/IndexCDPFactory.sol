// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IndexCDP.sol";
import "./SP500CDP.sol";

contract IndexCDPFactory is Ownable {
   event IndexCDPDeployed(address indexed cdpContract, string indexType);

   constructor(address initialOwner) Ownable(initialOwner) {}

   // Function to deploy a generic IndexCDP contract

function deployIndexCDP(
 address collateralToken,
 uint256 minimumCollateralAmount,
 uint256 liquidationThreshold
) external onlyOwner returns (address) {
 IndexCDP cdp = new IndexCDP(
   collateralToken,
   msg.sender, // Pass the msg.sender as the second argument
   liquidationThreshold,
   minimumCollateralAmount
 );
 emit IndexCDPDeployed(address(cdp), "Generic");
 return address(cdp);
}





   // Function to deploy a specific SP500CDP contract
   function deploySP500CDP(
       address collateralToken,
       uint256 minimumCollateralAmount,
       uint256 SP500CollateralizationRatio,
       uint256 SP500LiquidationThreshold,
       uint256 SP500StabilityFee
   ) external onlyOwner returns (address) {
       SP500CDP sp500Cdp = new SP500CDP(
           collateralToken,
           minimumCollateralAmount,
           SP500CollateralizationRatio,
           SP500LiquidationThreshold,
           SP500StabilityFee,
           msg.sender
       );
       emit IndexCDPDeployed(address(sp500Cdp), "SP500");
       return address(sp500Cdp);
   }

   // Add more deployment functions for other specific types of Index CDPs if needed
   // ...

   // Any additional factory management functions can go here
   // ...
}
