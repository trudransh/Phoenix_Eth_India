// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IIndexCDP {
    // Function to create a new CDP, locking in collateral and generating debt.
    function createCDP(uint256 collateralAmount) external;

    // Function to add additional collateral to an existing CDP.
    function addCollateral(uint256 collateralAmount) external;

    // Function to remove collateral from a CDP, provided the CDP remains over-collateralized.
    function removeCollateral(uint256 collateralAmount) external;

    // Function to borrow additional debt against the collateral in a CDP.
    function borrowDebt(uint256 debtAmount) external;

    // Function to repay debt in a CDP.
    function repayDebt(uint256 debtAmount) external;

    // Function to liquidate a CDP if it becomes under-collateralized.
    function liquidateCDP() external;

    // Function to retrieve the current price of the asset via an oracle.
    function getLatestPrice() external view returns (uint256);

    // Events to log CDP activities.
    event CDPCreated(address indexed owner, uint256 collateral, uint256 debt);
    event CDPUpdated(address indexed owner, uint256 collateral, uint256 debt);
    event CDPLiquidated(address indexed owner);
}
