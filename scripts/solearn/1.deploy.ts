// write code deploy agentUpgradeable and agentFactory
const { ethers, upgrades } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const AgentUpgradeable = await ethers.getContractFactory("AgentUpgradeable");
    const agentUpgradeable = await AgentUpgradeable.deploy();
    await agentUpgradeable.deployed();

    console.log("AgentUpgradeable deployed to:", agentUpgradeable.address);

    const contract = await ethers.getContractFactory("AgentFactory");
    console.log("AgentFactory.deploying ...")
    const proxy = await upgrades.deployProxy(contract, [deployer.address, agentUpgradeable.address], {
        initializer: 'initialize(address,address)',
    });
    await proxy.deployed();
    console.log("AgentFactory deployed at proxy:", proxy.address);
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});