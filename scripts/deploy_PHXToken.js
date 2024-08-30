const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying PHXToken with the account:", deployer.address);

  // Deploy PHXToken
  const PHXToken = await hre.ethers.getContractFactory("PHXToken");
  const phxToken = await PHXToken.deploy("1000000000000000000000000"); // Deploy with 1 million tokens as initial supply
  await phxToken.deployed();

  console.log("PHXToken deployed to:", phxToken.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
