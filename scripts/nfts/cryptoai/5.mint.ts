import {CryptoAI} from "./cryptoAI";
import {initConfig} from "../../data/cryptoai";

async function main() {
    // if (process.env.NETWORK != "base_mainnet") {
    //     console.log("wrong network");
    //     return;
    // }

    let config = await initConfig();

    const dataContract = new CryptoAI(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    await dataContract.mint(config.contractAddress, 0, process.env.PUBLIC_KEY, 0, [1, 2, 3, 4, 5]);

}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});