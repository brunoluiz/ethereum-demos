const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Election", function () {
  const prepare = async () => {
    const Election = await ethers.getContractFactory("Election");
    const election = await Election.deploy();
    await election.deployed();
    return election;
  };

  const addCandidates = async (election, total) => {
    for (let i = 0; i < total; i++) {
      const tx = await election.addCandidate("foo");
      await tx.wait();
    }
  };

  it("should only allow owner to register candidate", async () => {
    const election = await prepare();

    const [sOwner, sElector] = await ethers.getSigners();
    const [owner, elector] = await Promise.all([
      election.connect(sOwner),
      election.connect(sElector),
    ]);

    await expect(elector.addCandidate("foo")).to.be.reverted;

    const tx = await owner.addCandidate("foo");
    await tx.wait();
    expect(await owner.candidatesTotal()).to.equal(1);
  });

  it("should only allow one vote per elector", async () => {
    const election = await prepare();
    await addCandidates(election, 2);

    const [_, sElector] = await ethers.getSigners();
    const elector = await election.connect(sElector);

    let tx = await elector.vote(0);
    await tx.wait();
    await expect(elector.vote(1)).to.be.reverted;

    const candidate = await elector.candidates(0);
    expect(candidate.votes.toNumber()).to.be.equal(1);
  });

  it("should revert on non-existing candidates", async () => {
    const election = await prepare();

    const [_, sElector] = await ethers.getSigners();
    const elector = await election.connect(sElector);

    await expect(elector.vote(0)).to.be.reverted;
  });

  it("should return the winner", async () => {
    const election = await prepare();
    await addCandidates(election, 2);

    const [sOwner, sElector1, sElector2, sElector3] = await ethers.getSigners();
    const [owner, elector1, elector2, elector3] = await Promise.all([
      election.connect(sOwner),
      election.connect(sElector1),
      election.connect(sElector2),
      election.connect(sElector3),
    ]);

    await (await elector1.vote(1)).wait();
    await (await elector2.vote(1)).wait();
    await (await elector3.vote(0)).wait();

    const winnerId = await election.winner();
    await expect(winnerId.toNumber()).to.equal(1);
  });

  it("should error on tie", async () => {
    const election = await prepare();
    await addCandidates(election, 2);

    const [sOwner, sElector1, sElector2, sElector3, sElector4] =
      await ethers.getSigners();
    const [_, elector1, elector2, elector3, elector4] = await Promise.all([
      election.connect(sOwner),
      election.connect(sElector1),
      election.connect(sElector2),
      election.connect(sElector3),
      election.connect(sElector4),
    ]);

    await (await elector1.vote(1)).wait();
    await (await elector2.vote(1)).wait();
    await (await elector3.vote(0)).wait();
    await (await elector4.vote(0)).wait();

    await expect(election.winner()).to.be.revertedWith("tie");
  });
});
