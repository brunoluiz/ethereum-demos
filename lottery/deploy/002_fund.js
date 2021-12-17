const { networkConfig } = require("../utils/chainlink");

const func = async function (hre) {
  const { deployments } = hre;
  const { get } = deployments;
  const chainId = await getChainId();

  const config = networkConfig[chainId];
  if (!config) {
    throw new Error("missing config for chain");
  }

  const RandomGeneratorVRF = await get("RandomGeneratorVRF");
  const randomGeneratorVRF = await ethers.getContractAt(
    "RandomGeneratorVRF",
    RandomGeneratorVRF.address
  );

  const { address } = randomGeneratorVRF;
  const { linkTokenAddress, name } = config;

  if (await autoFundCheck(address, name, linkTokenAddress, "")) {
    await hre.run("fund-link", {
      contract: randomGeneratorVRF.address,
      linkaddress: linkTokenAddress,
    });
    log("auto funded RandomGeneratorVRF", address);
  }
};

func.tags = ["all"];
module.exports = func;
