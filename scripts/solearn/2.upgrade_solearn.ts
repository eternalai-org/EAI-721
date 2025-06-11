// write code deploy agentUpgradeable and agentFactory
const { ethers, upgrades } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Upgrade contracts with the account:", deployer.address);

    const AgentUpgradeable = await ethers.getContractFactory("AgentUpgradeable");
    const agentUpgradeable = await AgentUpgradeable.deploy();
    await agentUpgradeable.deployed();

    console.log("AgentUpgradeable deployed to:", agentUpgradeable.address);

    const contractUpdated = await ethers.getContractFactory("AgentFactory");
    const proxy = await upgrades.upgradeProxy(process.env.AGENT_FACTORY_ADDRESS, contractUpdated);
    console.log('AgentFactory upgraded on tx address ' + proxy.address);

    // set new implementation
    const tx = await proxy.setImplementation(agentUpgradeable.address);
    console.log('AgentFactory implementation set on tx address ' + await tx);
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});