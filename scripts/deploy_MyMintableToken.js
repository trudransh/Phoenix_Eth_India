const hre = require("hardhat");

async function main() {
  // Get the deployer's account
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying MyMintableToken with the account:", deployer.address);

  // Set your constructor parameters here
  const name = "MyMintableToken"; // Replace with actual token name if different
  const symbol = "MTK"; // Replace with actual token symbol if different

  try {
    // Get the contract factory for MyMintableToken
    const MyMintableToken = await hre.ethers.getContractFactory("MyMintableToken");

    // Deploy the contract with manual gas limit
    const myMintableToken = await MyMintableToken.deploy(name, symbol, {
      gasLimit: 50000000, // Adjust the gas limit as needed
    });

    // Wait until the contract is deployed
    await myMintableToken.deployed();

    console.log("MyMintableToken deployed to:", myMintableToken.address);
  } catch (error) {
    console.error("Deployment failed:", error.message);
    process.exit(1);
  }
}

// Run the main function and catch any errors
main().catch((error) => {
  console.error("Script error:", error);
  process.exit(1);
});
