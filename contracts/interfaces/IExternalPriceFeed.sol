// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IExternalPriceFeed {
    function readAsUint256(address sender) external view returns (uint256);
}
