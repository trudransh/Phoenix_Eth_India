# PHOENIX

This project demonstrates a DeFi application using a Collateral Debt Position (CDP) Factory and real-world price feeds provided by Chainsight to create a stablecoin pegged to the S&P 500, named `PHX_SP500`. It includes smart contracts for deploying and managing liquidity, trading on automated market makers (AMMs), and facilitating arbitrage opportunities.

## Contracts Deployed on Opencampus Network

Below is the list of all the smart contracts deployed on the Opencampus network with their respective addresses:

- **PHXToken**: `0x52ffB51b8F709B80e3B6613bE3F72B728d545D30`
- **MyMintableToken**: `0x2FE4fc4ab52BA6730c796F7feEeBA4f4dB4d5eca`
- **IndexCDPFactory**: `0xA5df2A82B04767d31920e0F2285B55998f27eC8A`
- **LiquidityProvider**: `0xB5B46FC92E1738a7c9DdCb84A2dD4932df66856F`

## Project Overview

The Phoenix Project aims to bridge the gap between real-world assets (RWA) and decentralized finance (DeFi) by allowing users to issue stablecoins pegged to traditional financial indices such as the S&P 500. The project utilizes a CDP Factory to create CDPs that mint stablecoins backed by real-world asset data provided by Chainsight.

### Prerequisite

1. **Price Feeds**: Chainsight provides the index data (e.g., S&P 500) hourly to the Price Feed (E) on the EVM network.

### Roles and Responsibilities

#### System Administrator

1. **Deployment**:
   - Deploys **IndexCDPFactory (A)** and **IndexLiquidityProvider (F)**.
2. **Pool Creation**:
   - Creates multiple pools for each Index CDP (e.g., B, C, D) from the deployed **IndexCDPFactory (A)**.

#### DeFi User (Liquidity Provider)

1. **Deposit**:
   - Deposits `$USDC` to **IndexLiquidityProvider (F)**.
   - **IndexLiquidityProvider (F)** allocates some amount of `$USDC` to an **IndexCDP (C)**.
   - Receives `PHX_SP500` tokens issued by **IndexCDP (C)**.
   - Adds liquidity of the pair (`USDC/PHX_SP500`) to Uniswap V2 (G).

2. **Position Closure**:
   - Closes the position to receive `$USDC` and earned fees.
   - **IndexLiquidityProvider (F)** removes liquidity of the pair from Uniswap V2 (G).
   - Returns some `PHX_SP500` tokens to **IndexCDP (C)**.
   - Receives `$USDC` from **IndexCDP (C)**.

#### DeFi User (Trader)

- Trades `PHX_SP500` tokens on the AMM, such as Uniswap V2.

#### Arbitrage Trader / Botter

1. **Arbitrage**:
   - Arbitrages based on price differences between the AMM and the current market price.
   - Redeems `PHX_SP500` acquired in the market through the CDP (similar to Liquity protocol).

## Target Index

The following indices are available for tokenization through this project:

- Chainsight 20 (Crypto Market Index)
- S&P 500 Index Token (US Stock Market Index)
- S&P Global REIT

## Concept

The project leverages a Collateral Debt Position (CDP) Factory combined with real-world price feeds provided by Chainsight to enable the tokenization of Real-World Assets (RWA). Users can issue tokens pegged to traditional financial indices, such as the S&P 500, by deploying and interacting with smart contracts on the blockchain.

## Problem Statement

Currently, tokenizing Real-World Assets (RWA) in DeFi is limited and challenging due to several issues:

1. **Real-Time Price Feeds**: Difficulty in obtaining real-time prices for indices like the S&P 500.
2. **CDP Limitations**: No current CDPs issue tokens pegged to indices like the S&P 500.
3. **Liquidity Challenges**: To stabilize token prices, the issued tokens must maintain adequate liquidity on AMMs.

To fully integrate RWAs like gold, REITs, or government bonds into DeFi, each asset must meet these requirements, which poses significant challenges and delays for widespread adoption in DeFi.

## Getting Started

To get started with this project, run the following commands:

```bash
npx hardhat compile
npx hardhat run scripts/deploy_PHXToken.js --network opencampus
npx hardhat run scripts/deploy_MyMintableToken.js --network opencampus
npx hardhat run scripts/deploy_IndexCDPFactory.js --network opencampus  
npx hardhat run scripts/deploy_LiquidityProvider.js --network opencampus