const hre = require("hardhat");

async function main() {
  const Election = await hre.ethers.getContractFactory("Election");
  const election = await Election.attach(
    "0x95e69f17a776cdbfc9c1ac51b53075c6bbea3643"
  );

  // const tx = await election.addCandidate("@brunoluiz");
  // await tx.wait();
  console.log(await election.candidatesTotal());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
