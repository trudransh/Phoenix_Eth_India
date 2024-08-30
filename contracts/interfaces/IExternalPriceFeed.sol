// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
interface IExternalPriceFeed {
   function readAsUint256(address sender) external view returns (uint256);
   function getLatestPrice() external view returns (uint256);
}
