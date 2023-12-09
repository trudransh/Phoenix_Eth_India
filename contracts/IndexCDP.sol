// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Mintable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IndexCDP is ReentrancyGuard, Ownable {
    IERC20 public collateralToken;
    IERC20Mintable public debtToken; // Assuming your PHX token has minting capabilities
    IPriceFeedOracle public priceOracle;
    struct CDP {
        uint256 collateralAmount;
        uint256 debtAmount;
        uint256 lastInteractionTime; // Keeping track of the last interaction for interest calculation
    }

    mapping(address => CDP) public cdps;

    uint256 public minimumCollateralAmount; // Define a minimum collateral amount
    uint256 public liquidationThreshold; // The threshold at which a CDP is subject to liquidation

    event CDPCreated(address indexed owner, uint256 collateral, uint256 debt);
    event CDPUpdated(address indexed owner, uint256 collateral, uint256 debt);
    event CDPLiquidated(address indexed owner);

    constructor(
        address _collateralToken,
        address _debtToken,
        uint256 _minimumCollateralAmount,
        uint256 _liquidationThreshold
    ) {
        collateralToken = IERC20(_collateralToken);
        debtToken = IERC20Mintable(_debtToken);
        minimumCollateralAmount = _minimumCollateralAmount;
        liquidationThreshold = _liquidationThreshold;
    }

    function createCDP(uint256 collateralAmount) external nonReentrant {
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
        cdps[msg.sender] = CDP({
            collateralAmount: collateralAmount,
            debtAmount: debtAmount,
            lastInteractionTime: block.timestamp
        });

        debtToken.mint(msg.sender, debtAmount);
        emit CDPCreated(msg.sender, collateralAmount, debtAmount);
    }

    // Implement other functions such as addCollateral, removeCollateral, borrowDebt, repayDebt based on your system's logic

    function calculateDebtAmount(uint256 collateralAmount)
        internal
        view
        returns (uint256)
    {
        // Implement your system's logic to calculate debt amount based on the collateral
        return collateralAmount * 2; // Example logic
    }

    function isSubjectToLiquidation(address cdpOwner)
        public
        view
        returns (bool)
    {
        CDP memory cdp = cdps[cdpOwner];
        // Replace this with your system's logic to check for under-collateralization
        return cdp.collateralAmount * liquidationThreshold < cdp.debtAmount;
    }

    function liquidateCDP(address cdpOwner) external nonReentrant {
        require(
            isSubjectToLiquidation(cdpOwner),
            "CDP is not subject to liquidation"
        );
        // Add logic for liquidation
        // ...

        emit CDPLiquidated(cdpOwner);
    }

    // Remove setPriceFeed function since Chainlink price feed is no longer used

    modifier cdpExists(address cdpOwner) {
        require(cdps[cdpOwner].collateralAmount > 0, "CDP does not exist");
        _;
    }

    // Owner can update the liquidation threshold
    function updateLiquidationThreshold(uint256 _newThreshold)
        external
        onlyOwner
    {
        require(_newThreshold > 0, "Threshold must be positive");
        liquidationThreshold = _newThreshold;
    }
}
