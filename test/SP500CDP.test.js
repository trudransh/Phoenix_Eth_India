const { expect } = require("chai");

describe("SP500CDP", function () {
   let SP500CDP;
   let hardhatSP500CDP;
   let owner;
   let addr1;
   let addr2;
   let addrs;

   beforeEach(async function () {
       SP500CDP = await ethers.getContractFactory("SP500CDP");
       [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

       hardhatSP500CDP = await SP500CDP.deploy();
   });

   describe("Deployment", function () {
       it("Should set the right owner", async function () {
           expect(await hardhatSP500CDP.owner()).to.equal(owner.address);
       });
   });

   describe("createCDP", function () {
       it("Should create a CDP with the correct collateral amount", async function () {
           await hardhatSP500CDP.createCDP(ethers.utils.parseEther("1.0"));
           const cdp = await hardhatSP500CDP.cdps(owner.address);
           expect(cdp.collateralAmount).to.equal(ethers.utils.parseEther("1.0"));
       });
   });

   describe("calculateSP500DebtAmount", function () {
       it("Should calculate the correct debt amount", async function () {
           const collateralAmount = ethers.utils.parseEther("1.0");
           const debtAmount = await hardhatSP500CDP.calculateSP500DebtAmount(collateralAmount);
           const expectedDebtAmount = (collateralAmount * SP500CollateralizationRatio) / 100;
           expect(debtAmount).to.equal(expectedDebtAmount);
       });
   });

   describe("setSP500Parameters", function () {
       it("Should update the parameters correctly", async function () {
           const newCollateralizationRatio = 200;
           const newLiquidationThreshold = 150;
           const newStabilityFee = 50;

           await hardhatSP500CDP.setSP500Parameters(newCollateralizationRatio, newLiquidationThreshold, newStabilityFee);

           expect(await hardhatSP500CDP.SP500CollateralizationRatio()).to.equal(newCollateralizationRatio);
           expect(await hardhatSP500CDP.SP500LiquidationThreshold()).to.equal(newLiquidationThreshold);
           expect(await hardhatSP500CDP.SP500StabilityFee()).to.equal(newStabilityFee);
       });
   });
});
