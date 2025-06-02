import { CryptoAIData } from "./cryptoAIData";
import { initConfig, updateConfig } from "./index";

async function main() {
    // if (process.env.NETWORK != "base_mainnet") {
    //     console.log("wrong network");
    //     return;
    // }

    await initConfig();

    const dataContract = new CryptoAIData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    const address = await dataContract.deploy(process.env.PUBLIC_KEY)
    console.log('CryptoAIData contract address:', address);
    const temp = await dataContract.getDeployer(address);
    console.log("deployer address:", temp);
    await updateConfig("dataContractAddress", address);
    console.log('Deploy succesful');
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});