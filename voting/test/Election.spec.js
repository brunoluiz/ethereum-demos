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
});
