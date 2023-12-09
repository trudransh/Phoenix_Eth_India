// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./oracles/PriceFeedOracle.sol";
import "./interfaces/IIndexCDP.sol";
import "./libraries/CDPHelper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "contracts/MyMintableToken.sol";

contract IndexCDP is ReentrancyGuard, AccessControl {
    IERC20 public collateralToken;
    MyMintableToken public phxToken;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

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
        address _phxToken,
        uint256 _minimumCollateralAmount,
        uint256 _liquidationThreshold
    ) {
        grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        grantRole(MINTER_ROLE, msg.sender);

        collateralToken = IERC20(_collateralToken);
        phxToken = MyMintableToken(_phxToken);
        minimumCollateralAmount = _minimumCollateralAmount;
        liquidationThreshold = _liquidationThreshold;
    }

    function createCDP(uint256 collateralAmount) external nonReentrant {
        require(collateralAmount >= minimumCollateralAmount, "Collateral is too low");
        require(collateralToken.transferFrom(msg.sender, address(this), collateralAmount), "Transfer failed");

        uint256 debtAmount = calculateDebtAmount(collateralAmount);
        cdps[msg.sender] = CDP({
            collateralAmount: collateralAmount,
            debtAmount: debtAmount,
            lastInteractionTime: block.timestamp
        });

        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        phxToken.mint(msg.sender, debtAmount);
        emit CDPCreated(msg.sender, collateralAmount, debtAmount);
    }

    // Other CDP related functions...

    function calculateDebtAmount(uint256 collateralAmount) internal view returns (uint256) {
        // Implement your logic here...
        return collateralAmount * 2; // Placeholder
    }

    function isSubjectToLiquidation(address cdpOwner) public view returns (bool) {
        CDP memory cdp = cdps[cdpOwner];
        // Replace this with your logic...
        return cdp.collateralAmount * liquidationThreshold < cdp.debtAmount;
    }

    function liquidateCDP(address cdpOwner) external nonReentrant {
        require(isSubjectToLiquidation(cdpOwner), "CDP is not subject to liquidation");
        // Liquidation logic...
        emit CDPLiquidated(cdpOwner);
    }

    // Function to update role-based access controls
    function updateMinterRole(address minter, bool hasAccess) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (hasAccess) {
            grantRole(MINTER_ROLE, minter);
        } else {
            revokeRole(MINTER_ROLE, minter);
        }
    }

    // Other utility functions...
}