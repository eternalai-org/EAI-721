import * as fs from "fs";
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
  let tokenCannotMint: any[] = [];

  const args = process.argv.slice(2) as string[];
  if (args.length == 0) {
    console.log("missing key");
  }
  const key = args[0];
  const addressToMint = args[1];
  const privateKey = args[2];

  console.log("Index:", key, "TokenId: ", data[key].token_id, "Address: ", addressToMint);
  console.log(data[key].id, data[key].data_mint[0], data[key].data_mint[1]);

  const dataContract = new CryptoAI(
    process.env.NETWORK,
    privateKey,
    addressToMint
  );
  await dataContract.mint(
    config.contractAddress,
    0,
    data[key].token_id,
    addressToMint,
    data[key].data_mint[0],
    data[key].data_mint[1]
  ).catch((error) => {
    tokenCannotMint.push({
      index: key,
      token_id: data[key].token_id,
      dna: data[key].data_mint[0],
      elements: data[key].data_mint[1],
    });
  });

   await fs.writeFileSync(
    `scripts/data/cryptoai/datajson/collections_nfs_be_id_not_mint_${addressToMint}.json`,
    JSON.stringify(tokenCannotMint, null, 2)
  );
}

main(1).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
