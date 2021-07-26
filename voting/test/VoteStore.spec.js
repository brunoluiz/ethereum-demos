const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VoteStore", function () {
  it("should be able to register a vote", async function () {
    const VoteStore = await ethers.getContractFactory("VoteStore");
    const voteStore = await VoteStore.deploy();
    await voteStore.deployed();

    const voteTx = await voteStore.vote(0xcafe);
    await voteTx.wait();
    expect(await voteStore.votesTotal()).to.equal(1);

    const [signer] = await ethers.getSigners();
    const addr = await signer.getAddress();
    const voteId = await voteStore.voteByVoter(addr);
    expect(await voteStore.votes(voteId)).to.equal(0xcafe);
  });
});
