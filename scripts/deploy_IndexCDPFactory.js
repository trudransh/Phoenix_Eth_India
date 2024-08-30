const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying IndexCDPFactory with the account:", deployer.address);

  // Deploy IndexCDPFactory
  const IndexCDPFactory = await hre.ethers.getContractFactory("IndexCDPFactory");
  const indexCDPFactory = await IndexCDPFactory.deploy(deployer.address); // Use the deployer's address as the owner
  await indexCDPFactory.deployed();

  console.log("IndexCDPFactory deployed to:", indexCDPFactory.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
