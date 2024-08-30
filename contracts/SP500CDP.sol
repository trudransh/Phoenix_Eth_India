// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IndexCDP.sol";
import "contracts/interfaces/IExternalPriceFeed.sol";

import "contracts/MyMintableToken.sol";

contract SP500CDP is IndexCDP {
    uint256 public SP500CollateralizationRatio;
    uint256 public SP500LiquidationThreshold;
    uint256 public SP500StabilityFee;
    IExternalPriceFeed externalPriceFeed;

    event SP500ParametersUpdated(
        uint256 collateralizationRatio,
        uint256 liquidationThreshold,
        uint256 stabilityFee
    );

    constructor(
        address _collateralToken,
        address _priceFeedAddress,
        address _phxToken,
        address _uniswapV2Router,
        uint256 _minimumCollateralAmount,
        uint256 _SP500CollateralizationRatio,
        uint256 _SP500LiquidationThreshold,
        uint256 _SP500StabilityFee
    )
        IndexCDP(
            _collateralToken,
            _phxToken,
            _uniswapV2Router,
            _minimumCollateralAmount,
            _SP500LiquidationThreshold // Assuming this is the same as liquidationThreshold
        )
    {
        externalPriceFeed = IExternalPriceFeed(_priceFeedAddress);
        SP500CollateralizationRatio = _SP500CollateralizationRatio;
        SP500LiquidationThreshold = _SP500LiquidationThreshold;
        SP500StabilityFee = _SP500StabilityFee;
    }

    function fetchLatestSP500Price() public view returns (uint256) {
        uint256 rawPrice = externalPriceFeed.getLatestPrice();
        uint256 formattedPrice = rawPrice / 1e6; // Convert to a number with two decimal places, assuming the price is given in 8 decimal places
        return formattedPrice;
    }

    function createCDP(uint256 collateralAmount) public override {
        // Custom logic for S&P 500 CDP creation
        require(
            collateralAmount >= minimumCollateralAmount,
            "Collateral is too low"
        );
        uint256 debtAmount = calculateSP500DebtAmount(collateralAmount);

        cdps[msg.sender] = CDP(collateralAmount, debtAmount, block.timestamp);
        // emit CDPCreated(msg.sender, collateralAmount, debtAmount);
    }

    function calculateSP500DebtAmount(uint256 collateralAmount)
        internal
        view
        returns (uint256)
    {
        // Implement specific debt calculation logic for SP500
        return (collateralAmount * SP500CollateralizationRatio) / 100;
    }

    function setSP500Parameters(
        uint256 newCollateralizationRatio,
        uint256 newLiquidationThreshold,
        uint256 newStabilityFee
    ) external onlyRole(MINTER_ROLE) {
        SP500CollateralizationRatio = newCollateralizationRatio;
        SP500LiquidationThreshold = newLiquidationThreshold;
        SP500StabilityFee = newStabilityFee;
        emit SP500ParametersUpdated(
            newCollateralizationRatio,
            newLiquidationThreshold,
            newStabilityFee
        );
    }

    // Override other necessary functions from IndexCDP as needed
    // ...

    // Implement any additional functions specific to SP500CDP
    // ...
}
