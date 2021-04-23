var land = artifacts.require("./land.sol");

module.exports = function(deployer) {
  deployer.deploy(land);
};