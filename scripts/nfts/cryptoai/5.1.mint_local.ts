import { initConfig } from "../../data/cryptoai";
import { CryptoAI } from "./cryptoAI";
// const data = require("../../data/cryptoai/datajson/collections.json");
const data = require("../../data/cryptoai/datajson/collections_nfs_be.json");

async function main(tokenId: any) {
  // if (process.env.NETWORK != "base_mainnet") {
  //     console.log("wrong network");
  //     return;
  // }

  let config = await initConfig();

  const args = process.argv.slice(2) as string[];
  if (args.length == 0) {
    console.log("missing key");
  }
  const key = args[0];

  const dataContract = new CryptoAI(
    process.env.NETWORK,
    process.env.PRIVATE_KEY,
    process.env.PUBLIC_KEY
  );
  await dataContract.mint(
    config.contractAddress,
    0,
    data[key].token_id,
    process.env.PUBLIC_KEY,
    data[key].data_mint[0],
    data[key].data_mint[1]
  );
}

main(1).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
