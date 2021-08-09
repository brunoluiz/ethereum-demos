const { expect } = require("chai");
const { ethers } = require("hardhat");

const { parseEther } = ethers.utils;

describe("Lottery", function () {
  let owner, addr1, addr2, addrs, lottery, provider;
  let lottoId = 0;

  beforeEach(async () => {
    const RandomGeneratorVRF = await ethers.getContractFactory(
      "MockRandomGeneratorVRF"
    );
    randomGeneratorVRF = await RandomGeneratorVRF.deploy();
    await randomGeneratorVRF.deployed();

    const Lottery = await ethers.getContractFactory("Lottery");
    lottery = await Lottery.deploy(randomGeneratorVRF.address);
    await lottery.deployed();

    const tx = await lottery.createLottery(parseEther("0.001"));
    await tx.wait();

    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    provider = ethers.provider;
  });

  const buy = async (addr) => {
    const tx = await lottery
      .connect(addr)
      .buy(lottoId, { value: parseEther("0.001") });
    await tx.wait();
  };

  describe("buying tickets", () => {
    it("should buy ticket successfully", async () => {
      for (let i = 0; i < 2; i++) {
        await buy(addr1);
        await buy(addr2);
      }

      const l = await lottery.lotteries(lottoId);
      expect(await l.ticketCount).to.be.equal(4);
      expect(await l.funds).to.be.equal(parseEther("0.004"));
    });

    it("should fail to get ticket with incorrect value", async () => {
      await expect(
        lottery.connect(addr1).buy({
          value: ethers.utils.parseEther("0.0005"),
        })
      ).to.be.reverted;
    });

    it("should fail to get ticket after being drawn", async () => {
      await buy(addr1);

      tx = await lottery.draw(lottoId);
      await tx.wait();

      let l = await lottery.lotteries(lottoId);
      expect(l.status, 3);
      await expect(
        lottery.connect(addr1).buy({
          value: ethers.utils.parseEther("0.001"),
        })
      ).to.be.reverted;
    });
  });

  describe("drawing lottery", () => {
    it("should draw numbers and get a winner", async () => {
      for (let i = 0; i < 2; i++) {
        await buy(addr1);
        await buy(addr2);
      }

      let l = await lottery.lotteries(lottoId);
      expect(await l.ticketCount).to.be.equal(4);
      expect(await l.funds).to.be.equal(parseEther("0.004"));

      let tx = await lottery.draw(lottoId);
      await tx.wait();

      tx = await lottery.transfer(lottoId);
      await tx.wait();

      l = await lottery.lotteries(lottoId);
      expect(l.status).to.be.equal(3);
      expect(l.funds).to.be.equal(0);
    });

    it("should revert if try to draw twice", async () => {
      await buy(addr1);
      await buy(addr2);

      let tx = await lottery.draw(lottoId);
      await tx.wait();

      await expect(lottery.draw(lottoId)).to.be.reverted;
    });

    it("should revert if try to fulfill draw not being random generator", async () => {
      await expect(lottery.fulfillDraw(lottoId)).to.be.reverted;
    });
  });
});
