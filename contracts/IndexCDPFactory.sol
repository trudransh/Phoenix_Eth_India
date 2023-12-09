// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IndexCDP.sol";
import "./SP500CDP.sol";

// Import other specific CDP contracts as needed

contract IndexCDPFactory {
    // Event to log the creation of a new CDP contract
    event CDPContractCreated(
        address indexed cdpContractAddress,
        address indexed creator
    );

    // Function to create a new Index CDP contract
    function createIndexCDP(
        address priceFeed,
        address collateralToken,
        address debtToken,
        uint256 minimumCollateralAmount
    ) external returns (address) {
        IndexCDP cdp = new IndexCDP(
            priceFeed,
            collateralToken,
            debtToken,
            minimumCollateralAmount
        );
        emit CDPContractCreated(address(cdp), msg.sender);
        return address(cdp);
    }

    // Function to create a new S&P 500 CDP contract
    function createSP500CDP(
        address priceFeed,
        address collateralToken,
        address debtToken,
        uint256 minimumCollateralAmount
    ) external returns (address) {
        SP500CDP cdp = new SP500CDP(
            priceFeed,
            collateralToken,
            debtToken,
            minimumCollateralAmount
        );
        emit CDPContractCreated(address(cdp), msg.sender);
        return address(cdp);
    }

    // Add more functions to create other specific types of CDPs as necessary
}
