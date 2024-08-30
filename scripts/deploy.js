const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  // Manually set gas limit for transactions
  const gasLimit = 5000000; // Example gas limit, adjust as necessary

  // Deploy PHXToken
  const PHXToken = await hre.ethers.getContractFactory("PHXToken");
  const phxToken = await PHXToken.deploy("1000000000000000000000000", {
    gasLimit: gasLimit,
  });
  await phxToken.deployed();
  console.log("PHXToken deployed to:", phxToken.address);

  // Deploy MyMintableToken
  const MyMintableToken = await hre.ethers.getContractFactory("MyMintableToken");
  const myMintableToken = await MyMintableToken.deploy("MintableToken", "MTK", {
    gasLimit: gasLimit,
  });
  await myMintableToken.deployed();
  console.log("MyMintableToken deployed to:", myMintableToken.address);

  // Deploy IndexCDPFactory
  const IndexCDPFactory = await hre.ethers.getContractFactory("IndexCDPFactory");
  const indexCDPFactory = await IndexCDPFactory.deploy(deployer.address, {
    gasLimit: gasLimit,
  });
  await indexCDPFactory.deployed();
  console.log("IndexCDPFactory deployed to:", indexCDPFactory.address);

  // Deploy LiquidityProvider
  const LiquidityProvider = await hre.ethers.getContractFactory("LiquidityProvider");
  const indexCDPAddress = "0x..."; // Replace with the deployed IndexCDP address if available
  const usdcTokenAddress = myMintableToken.address;
  const phxTokenAddress = phxToken.address;
  const uniswapV2RouterAddress = "0x..."; // Replace with actual Uniswap V2 Router address

  const liquidityProvider = await LiquidityProvider.deploy(
    indexCDPAddress,
    usdcTokenAddress,
    phxTokenAddress,
    uniswapV2RouterAddress,
    {
      gasLimit: gasLimit,
    }
  );
  await liquidityProvider.deployed();
  console.log("LiquidityProvider deployed to:", liquidityProvider.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
