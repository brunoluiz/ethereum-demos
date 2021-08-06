const { expect } = require("chai");
const { ethers } = require("hardhat");

const { parseEther } = ethers.utils;

const NORM = 1000000000;

describe("Lottery", function () {
  let owner, addr1, addr2, addrs, lottery, provider;
  const prepare = async () => {
    const Lottery = await ethers.getContractFactory("Lottery");

    const lottery = await Lottery.deploy();
    await lottery.deployed();
    const tx = await lottery.setTicketValue(parseEther("0.001"));
    await tx.wait();

    return lottery;
  };

  beforeEach(async () => {
    lottery = await prepare();
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    provider = ethers.provider;
  });

  describe("buying tickets", () => {
    it("should get ticket successfully", async () => {
      const l1 = await lottery.connect(addr1);
      const l2 = await lottery.connect(addr2);

      for (let i = 0; i < 2; i++) {
        let tx;
        tx = await l1.buy({ value: parseEther("0.001") });
        await tx.wait();

        tx = await l2.buy({ value: parseEther("0.001") });
        await tx.wait();
      }

      expect(await lottery.ticketsTotal()).to.be.equal(4);
      expect(await lottery.funds()).to.be.equal(parseEther("0.004"));

      for (let i = 0; i < 2; i++) {
        let ticketId, ticket;
        ticketId = await lottery.ticketByWallet(addr1.address, i);
        ticket = await lottery.tickets(ticketId.toNumber());
        expect(ticket).to.be.equal(addr1.address);

        ticketId = await lottery.ticketByWallet(addr2.address, i);
        ticket = await lottery.tickets(ticketId.toNumber());
        expect(ticket).to.be.equal(addr2.address);
      }
    });

    it("should fail to get ticket", async () => {
      await expect(
        lottery.connect(addr1).buy({
          value: ethers.utils.parseEther("0.0005"),
        })
      ).to.be.reverted;
    });
  });

  describe("winner", () => {
    it("should get winner", async () => {
      const l1 = await lottery.connect(addr1);
      const l2 = await lottery.connect(addr2);
      for (let i = 0; i < 2; i++) {
        let tx;
        tx = await l1.buy({
          value: ethers.utils.parseEther("0.001"),
        });
        await tx.wait();

        tx = await l2.buy({
          value: ethers.utils.parseEther("0.001"),
        });
        await tx.wait();
      }

      expect(await lottery.ticketsTotal()).to.be.equal(4);
      expect(await lottery.funds()).to.be.equal(parseEther("0.004"));

      let tx = await lottery.roll();
      await tx.wait();

      tx = await lottery.transfer();
      await tx.wait();

      const status = await lottery.status();
      expect(status.finished).to.be.equal(true);
    });
  });
});
