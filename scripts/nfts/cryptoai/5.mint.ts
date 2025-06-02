import { initConfig } from "../../data/cryptoai";
import { CryptoAI } from "./cryptoAI";
const data = require("../../data/cryptoai/datajson/collections.json");

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
  console.log(data[key].id, data[key].index[0], data[key].index[1]);
  await dataContract.mint(
    config.contractAddress,
    0,
    data[key].id,
    process.env.PUBLIC_KEY,
    data[key].index[0],
    data[key].index[1]
  );
}

main(1).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
