// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Additional imports as necessary...
contract IndexCDP is ReentrancyGuard, Ownable {
    AggregatorV3Interface public priceFeed;
    IERC20 public collateralToken;
    IERC20 public debtToken; // This will be your PHX token or equivalent

    struct CDP {
        uint256 collateralAmount;
        uint256 debtAmount;
        // Additional parameters like interest rate, last interaction time, etc.
    }

    mapping(address => CDP) public cdps;

    event CDPCreated(address indexed owner, uint256 collateral, uint256 debt);
    event CDPUpdated(address indexed owner, uint256 collateral, uint256 debt);
    event CDPLiquidated(address indexed owner);

    constructor(
        address _priceFeed,
        address _collateralToken,
        address _debtToken
    ) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        collateralToken = IERC20(_collateralToken);
        debtToken = IERC20(_debtToken);
    }

    function createCDP(uint256 collateralAmount) external nonReentrant {
        require(
            collateralAmount >= minimumCollateralAmount,
            "Collateral is too low"
        );

        // Ensure the contract is allowed to transfer the collateral tokens
        require(
            collateralToken.allowance(msg.sender, address(this)) >=
                collateralAmount,
            "Insufficient token allowance"
        );

        // Transfer collateral from the user to this contract
        collateralToken.transferFrom(
            msg.sender,
            address(this),
            collateralAmount
        );

        // Calculate the maximum debt amount based on the collateral
        // For simplicity, let's say 1 collateral unit allows for 2 debt units
        // In a real scenario, you would replace this with a more complex calculation
        uint256 debtAmount = collateralAmount * 2;

        // Create a new CDP record
        CDP storage newCDP = cdps[msg.sender];
        newCDP.collateralAmount = collateralAmount;
        newCDP.debtAmount = debtAmount;

        // Mint debt tokens to the user
        // This assumes that `debtToken` is a mintable token and this contract has a minting role
        debtToken.mint(msg.sender, debtAmount);

        // Emit an event for the new CDP
        emit CDPCreated(msg.sender, collateralAmount, debtAmount);
    }

    function addCollateral(address cdpOwner, uint256 collateralAmount)
        external
        nonReentrant
    {
        require(
            collateralAmount > 0,
            "Collateral amount must be greater than zero"
        );

        CDP storage userCDP = cdps[cdpOwner];
        require(userCDP.collateralAmount > 0, "CDP does not exist");

        require(
            collateralToken.allowance(msg.sender, address(this)) >=
                collateralAmount,
            "Insufficient token allowance"
        );

        // Transfer additional collateral to the contract
        collateralToken.transferFrom(
            msg.sender,
            address(this),
            collateralAmount
        );

        // Update the CDP record
        userCDP.collateralAmount = userCDP.collateralAmount + collateralAmount;

        // Emit an event to log the collateral addition
        emit CDPUpdated(cdpOwner, userCDP.collateralAmount, userCDP.debtAmount);
    }

    function removeCollateral(address cdpOwner, uint256 collateralAmount)
        external
        nonReentrant
    {
        require(
            collateralAmount > 0,
            "Collateral amount must be greater than zero"
        );

        CDP storage userCDP = cdps[cdpOwner];
        require(
            userCDP.collateralAmount >= collateralAmount,
            "Insufficient collateral in CDP"
        );

        // Check if the CDP remains over-collateralized after removal
        // This is a simplified version. In a real scenario, you would replace this
        // with a more complex calculation involving the current price of the underlying asset
        require(
            userCDP.debtAmount * 2 <=
                (userCDP.collateralAmount - collateralAmount),
            "CDP would become under-collateralized"
        );

        // Update the CDP record
        userCDP.collateralAmount = userCDP.collateralAmount - collateralAmount;

        // Transfer the collateral back to the user
        collateralToken.transfer(cdpOwner, collateralAmount);

        // Emit an event to log the collateral removal
        emit CDPUpdated(cdpOwner, userCDP.collateralAmount, userCDP.debtAmount);
    }

    function borrowDebt(uint256 debtAmount) external nonReentrant {
        require(debtAmount > 0, "Debt amount must be greater than zero");

        CDP storage userCDP = cdps[msg.sender];
        require(userCDP.collateralAmount > 0, "CDP does not exist");

        // Check if the CDP remains over-collateralized after borrowing
        // This is a simplified version. In a real scenario, you would replace this
        // with a more complex calculation involving the current price of the underlying asset
        uint256 maxDebt = userCDP.collateralAmount / 2; // Example ratio
        require(
            userCDP.debtAmount + debtAmount <= maxDebt,
            "CDP would become under-collateralized"
        );

        // Update the CDP record with the new debt amount
        userCDP.debtAmount = userCDP.debtAmount + debtAmount;

        // Mint debt tokens to the CDP owner
        // Ensure that the debtToken is a mintable token and this contract has the minting role
        debtToken.mint(msg.sender, debtAmount);

        // Emit an event to log the borrowing
        emit CDPUpdated(
            msg.sender,
            userCDP.collateralAmount,
            userCDP.debtAmount
        );
    }

    function repayDebt(uint256 debtAmount) external nonReentrant {
        require(debtAmount > 0, "Debt amount must be greater than zero");

        CDP storage userCDP = cdps[msg.sender];
        require(userCDP.debtAmount >= debtAmount, "Repayment exceeds debt");

        // Transfer debt tokens from the user to the contract or burn them
        require(
            debtToken.transferFrom(msg.sender, address(this), debtAmount),
            "Debt token transfer failed"
        );

        // Update the CDP record with the reduced debt amount
        userCDP.debtAmount = userCDP.debtAmount - debtAmount;

        emit CDPUpdated(
            msg.sender,
            userCDP.collateralAmount,
            userCDP.debtAmount
        );
    }

    function liquidateCDP(address cdpOwner) external nonReentrant {
        // Logic to liquidate under-collateralized CDPs
    }

    function getLatestPrice() public view returns (uint256) {
        // Logic to interact with the price feed oracle
    }

    function setPriceFeed(address _priceFeed) external onlyOwner {
        // Logic to update the price feed oracle address
    }

    modifier cdpExists(address cdpOwner) {
        require(cdps[cdpOwner].collateralAmount > 0, "CDP does not exist");
        _;
    }
}
