import * as fs from "fs";
import { initConfig } from "../../data/cryptoai";
import { CryptoAI } from "./cryptoAI";
const data = require("../../data/cryptoai/datajson/collections_nfs_be.json");

async function main() {
  // if (process.env.NETWORK != "local") {
  //     console.log("wrong network");
  //     return;
  // }

  let data_opensea: any[] = [];

  let config = await initConfig();

  const dataContract = new CryptoAI(
    process.env.NETWORK,
    process.env.PRIVATE_KEY,
    process.env.PUBLIC_KEY
  );
  //   const data = await dataContract.tokenURI(config.contractAddress, 1);

  for (let i = 1; i <= 10000; i++) {
    try {
      const tokenData = await dataContract
        .tokenURI("0x74cbE7cFbB7f392609b8e6aDC12F5D8018370D5d", i)
        .then( async(data: any) => {
          const data_opensea_item = {
            token_id: i,
            data: JSON.parse(data).attributes,
          }
          await data_opensea.push(data_opensea_item);
        });
      //   if (tokenData) {
      //     data_opensea.push({
      //       token_id: i,
      //       data: JSON.parse(tokenData).attributes,
      //     });
      //   }
      console.log(`Processed token ${i}`);
    } catch (error) {
      console.log(`Error processing token ${i}:`, error);
    }
  }

  await fs.writeFileSync(
    "scripts/data/cryptoai/datajson/collections_nfs_opensea.json",
    JSON.stringify(data_opensea, null, 2)
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
