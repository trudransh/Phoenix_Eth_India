const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying LiquidityProvider with the account:", deployer.address);

  // Ensure you have the addresses of the deployed contracts
  const indexCDPAddress = "0xA5df2A82B04767d31920e0F2285B55998f27eC8A"; // Replace with the actual deployed IndexCDP address
  const usdcTokenAddress = "0x2FE4fc4ab52BA6730c796F7feEeBA4f4dB4d5eca"; // Replace with the deployed MyMintableToken address
  const phxTokenAddress = "0x52ffB51b8F709B80e3B6613bE3F72B728d545D30"; // Replace with the deployed PHXToken address
  const uniswapV2RouterAddress = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"; // Replace with the actual Uniswap V2 Router address

  // Deploy LiquidityProvider
  const LiquidityProvider = await hre.ethers.getContractFactory("LiquidityProvider");
  const liquidityProvider = await LiquidityProvider.deploy(
    indexCDPAddress,
    usdcTokenAddress,
    phxTokenAddress,
    uniswapV2RouterAddress
  );
  await liquidityProvider.deployed();

  console.log("LiquidityProvider deployed to:", liquidityProvider.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
