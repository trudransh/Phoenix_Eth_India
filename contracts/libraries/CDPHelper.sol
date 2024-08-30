// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library CDPHelper {
    // Assuming a constant interest rate for simplicity. In practice, this could be dynamic.
    uint256 public constant INTEREST_RATE_PER_YEAR = 5; // 5% interest rate
    uint256 public constant SECONDS_IN_A_YEAR = 365 * 24 * 60 * 60;

    // Calculates the debt amount with accrued interest over time.
    function calculateAccruedDebt(
        uint256 initialDebt,
        uint256 lastInteractionTime
    ) internal view returns (uint256) {
        uint256 timeElapsed = block.timestamp - lastInteractionTime;
        uint256 interest = (initialDebt *
            INTEREST_RATE_PER_YEAR *
            timeElapsed) / (SECONDS_IN_A_YEAR * 100);
        return initialDebt + interest;
    }

    // Calculates the liquidation price for a CDP based on the debt and collateral.
    function calculateLiquidationPrice(
        uint256 collateralAmount,
        uint256 debtAmount,
        uint256 collateralizationRatio
    ) internal pure returns (uint256) {
        require(
            collateralizationRatio > 0,
            "Collateralization ratio must be positive"
        );
        return (debtAmount * collateralizationRatio) / collateralAmount;
    }

    // Calculates the stability fee (if any) for maintaining the CDP.
    function calculateStabilityFee(
        uint256 debtAmount,
        uint256 feePercentage,
        uint256 lastPaidTime
    ) internal view returns (uint256) {
        uint256 timeElapsed = block.timestamp - lastPaidTime;
        return
            (debtAmount * feePercentage * timeElapsed) /
            (SECONDS_IN_A_YEAR * 100);
    }

    // Additional utility functions you might need:

    // Determines the maximum amount of tokens that can be minted based on the collateral and the current price.
    function calculateMintableTokens(
        uint256 collateralAmount,
        uint256 priceFeedValue,
        uint256 mintRatio
    ) internal pure returns (uint256) {
        // This is a simplified formula; you may need to adjust it based on your tokenomics
        return (collateralAmount * priceFeedValue) / mintRatio;
    }

    // Determines whether enough time has passed to allow for certain actions (like collateral withdrawal or more debt issuance).
    function isActionAllowed(
        uint256 lastInteractionTime,
        uint256 minimumTimeElapsed
    ) internal view returns (bool) {
        return (block.timestamp - lastInteractionTime) > minimumTimeElapsed;
    }

    // ... other utility functions as per your system's needs.
}
