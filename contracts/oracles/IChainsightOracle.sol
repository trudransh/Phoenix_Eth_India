// SPDX-License-Identifier: UNLICENSED
// This is an interface to access unique data provided by Chainsight.
// To see more details: https://chainsight.network/
pragma solidity ^0.8.0;

interface IChainsightOracle {
    function updateState(bytes calldata data) external;

    event StateUpdated(address indexed sender, bytes data);

    function readAsString(address sender) external view returns (string memory);

    function readAsUint256(address sender) external view returns (uint256);

    function readAsUint128(address sender) external view returns (uint128);

    function readAsUint64(address sender) external view returns (uint64);
}
