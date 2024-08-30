// Import necessary dependencies
const { ethers } = require("hardhat");

async function main() {
  // Define the addresses and parameters for deployment
  const COLLATERAL_TOKEN_ADDRESS = "0x2FE4fc4ab52BA6730c796F7feEeBA4f4dB4d5eca"; // Replace with your MyMintableToken deployed address
  const PHX_TOKEN_ADDRESS = "0x52ffB51b8F709B80e3B6613bE3F72B728d545D30"; // Replace with your PHXToken deployed address
  const UNISWAP_V2_ROUTER_ADDRESS = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"; // Replace with your Uniswap V2 Router address

  const MINIMUM_COLLATERAL_AMOUNT = ethers.utils.parseEther("1"); // Example: 1 token as minimum collateral
  const LIQUIDATION_THRESHOLD = ethers.utils.parseEther("1.5"); // Example: 150% collateralization ratio

  // Get the contract to deploy
  const IndexCDP = await ethers.getContractFactory("IndexCDP");

  console.log("Deploying IndexCDP contract...");

  // Deploy the contract
  const indexCDP = await IndexCDP.deploy(
    COLLATERAL_TOKEN_ADDRESS,
    PHX_TOKEN_ADDRESS,
    UNISWAP_V2_ROUTER_ADDRESS,
    MINIMUM_COLLATERAL_AMOUNT,
    LIQUIDATION_THRESHOLD
  );

  await indexCDP.deployed();

  console.log("IndexCDP deployed to:", indexCDP.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
