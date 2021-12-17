const { networkConfig } = require("../utils/chainlink");

const func = async function (hre) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const chainId = await getChainId();
  const { deployer } = await getNamedAccounts();

  const config = networkConfig[chainId];
  if (!config) {
    throw new Error("missing config for chain");
  }

  const { oracle, jobId, fee, linkTokenAddress } = config;
  const { address } = await deploy("RandomGeneratorVRF", {
    from: deployer,
    args: [oracle, jobId, fee, linkTokenAddress],
    log: true,
  });
  log("deployed RandomGeneratorVRF", address);
};

func.tags = ["all", "vrf"];
module.exports = func;
