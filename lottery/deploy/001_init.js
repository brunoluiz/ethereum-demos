const func = async function (hre) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("Election", {
    from: deployer,
    log: true,
  });
};

func.tags = ["Election"];
module.exports = func;
