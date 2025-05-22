import { initConfig } from "../../data/cryptoai";
import { CryptoAI } from "./cryptoAI";

async function main() {
    // if (process.env.NETWORK != "local") {
    //     console.log("wrong network");
    //     return;
    // }

    let config = await initConfig();
    const args = process.argv.slice(2);
    if (args.length == 0) {
        console.log("missing number")
        return;
    }
    const dataContract = new CryptoAI(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    const data = await dataContract.tokenURI(config.contractAddress, args[0]);
    console.log(data);
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});