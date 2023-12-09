const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LiquidityProvider", function() {
 let LiquidityProvider, liquidityProvider, owner, addr1;
 let cdpContract, usdcToken, phxToken, uniswapRouter;

 beforeEach(async function() {
   // Here we get the contracts needed for the test
   liquidityProvider = await ethers.getContractFactory("LiquidityProvider");
   cdpContract = await liquidityProvider.deploy();

   IERC20 = await ethers.getContractFactory("@openzeppelin/contracts/token/ERC20/IERC20.sol");
   usdcToken = await IERC20.deploy();
   phxToken = await IERC20.deploy();

   IUniswapV2Router02 = await ethers.getContractFactory("@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol");
   uniswapRouter = await IUniswapV2Router02.deploy();

   LiquidityProvider = await ethers.getContractFactory("LiquidityProvider");
   [owner, addr1] = await ethers.getSigners();
   liquidityProvider = await LiquidityProvider.deploy(cdpContract.address, usdcToken.address, phxToken.address, uniswapRouter.address);
 });

 describe("depositUSDC", function() {
   it("Should deposit USDC to the contract", async function() {
     await usdcToken.transfer(addr1.address, 1000);
     await usdcToken.connect(addr1).approve(liquidityProvider.address, 1000);
     await liquidityProvider.connect(addr1).depositUSDC(1000);
     expect(await usdcToken.balanceOf(liquidityProvider.address)).to.equal(1000);
   });
 });

 describe("mintPHX", function() {
   it("Should mint PHX tokens", async function() {
       await liquidityProvider.connect(owner).mintPHX(1000);
       expect(await phxToken.balanceOf(liquidityProvider.address)).to.equal(1000);
   });

   it("Should only allow the owner to mint PHX tokens", async function() {
     await expect(liquidityProvider.connect(addr1).mintPHX(1000))
       .to.be.revertedWith("Ownable: caller is not the owner");
   });
 });

 describe("burnPHX", function() {
   it("Should burn PHX tokens", async function() {
       await liquidityProvider.connect(owner).mintPHX(1000);
       await liquidityProvider.connect(owner).burnPHX(500);
       expect(await phxToken.balanceOf(liquidityProvider.address)).to.equal(500);
   });

   it("Should only allow the owner to burn PHX tokens", async function() {
     await expect(liquidityProvider.connect(addr1).burnPHX(500))
       .to.be.revertedWith("Ownable: caller is not the owner");
   });
 });

 describe("addLiquidity", function() {
   it("Should add liquidity to Uniswap", async function() {
       await usdcToken.transfer(liquidityProvider.address, 1000);
       await liquidityProvider.connect(owner).mintPHX(1000);
       await expect(liquidityProvider.connect(owner).addLiquidity(1000, 1000))
       .to.emit(uniswapRouter, 'AddLiquidity')
       .withArgs(owner.address, 1000, 1000);
   });

   it("Should fail if the contract doesn't have enough tokens", async function() {
     await expect(liquidityProvider.connect(owner).addLiquidity(1000, 1000))
       .to.be.revertedWith("ERC20: transfer amount exceeds balance");
   });
 });
});
