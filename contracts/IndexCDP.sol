// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./oracles/PriceFeedOracle.sol";
import "./interfaces/IIndexCDP.sol";
import "./libraries/CDPHelper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IndexCDP is ReentrancyGuard, AccessControl {
    IERC20 public collateralToken;

    // Define a role for managing the CDP
    bytes32 public constant CDP_MANAGER_ROLE = keccak256("CDP_MANAGER_ROLE");

    struct CDP {
        uint256 collateralAmount;
        uint256 debtAmount;
        uint256 lastInteractionTime;
    }

    mapping(address => CDP) public cdps;

    uint256 public minimumCollateralAmount;
    uint256 public liquidationThreshold;

    event CDPCreated(address indexed owner, uint256 collateral, uint256 debt);
    event CDPUpdated(address indexed owner, uint256 collateral, uint256 debt);
    event CDPLiquidated(address indexed owner);

    constructor(
        address _collateralToken,
        uint256 _minimumCollateralAmount,
        uint256 _liquidationThreshold
    ) {
        collateralToken = IERC20(_collateralToken);
        minimumCollateralAmount = _minimumCollateralAmount;
        liquidationThreshold = _liquidationThreshold;

        // Setup CDP manager role
        _setupRole(CDP_MANAGER_ROLE, msg.sender);
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
        cdps[msg.sender] = CDP(collateralAmount, debtAmount, block.timestamp);

        emit CDPCreated(msg.sender, collateralAmount, debtAmount);
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

    function liquidateCDP(address cdpOwner) external nonReentrant {
        require(
            hasRole(CDP_MANAGER_ROLE, msg.sender),
            "Caller is not a CDP manager"
        );
        require(
            isSubjectToLiquidation(cdpOwner),
            "CDP is not subject to liquidation"
        );

        // Implement liquidation logic
        // ...

        emit CDPLiquidated(cdpOwner);
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
