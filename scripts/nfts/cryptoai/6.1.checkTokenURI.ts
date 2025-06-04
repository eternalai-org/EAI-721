import * as fs from "fs";
import { initConfig } from "../../data/cryptoai";
import { CryptoAI } from "./cryptoAI";
const data = require("../../data/cryptoai/datajson/collections_nfs_be.json");

async function main() {
    // if (process.env.NETWORK != "local") {
    //     console.log("wrong network");
    //     return;
    // }
    let tokenIdsNotFound: any[] = [];

    let config = await initConfig();
    // const args = process.argv.slice(2);
    // if (args.length == 0) {
    //     console.log("missing number")
    //     return;
    // }
    const dataContract = new CryptoAI(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    const promises = data.map(async (item: any, index: number) => {
        const data = await dataContract.tokenURI(config.contractAddress, item.token_id).catch(error => {
            console.log("Token not found", item.token_id);
            tokenIdsNotFound.push({
                index: index,
                token_id: item.token_id,
                dna: item.data_mint[0],
                elements: item.data_mint[1],
             });
        });
    });
    await Promise.all(promises);
    console.log(tokenIdsNotFound);
    await fs.writeFileSync(
      "scripts/data/cryptoai/datajson/collections_nfs_be_id_not_found.json",
      JSON.stringify(tokenIdsNotFound, null, 2),
    );
 }

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});