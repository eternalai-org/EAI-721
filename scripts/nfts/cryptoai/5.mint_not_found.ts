import { initConfig } from "../../data/cryptoai";
import { CryptoAI } from "./cryptoAI";
// const data = require("../../data/cryptoai/datajson/collections.json");
const data = require("../../data/cryptoai/datajson/collections_nfs_be_id_not_found.json");

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
  const addressToMint = args[1];
  const privateKey = args[2];

  console.log("Index:", key, "TokenId: ", data[key].token_id, "Address: ", addressToMint);
  console.log("DNA:", data[key].dna, "Elements:", data[key].elements);

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
    data[key].dna,
    data[key].elements
  );
}

main(1).catch((error) => {
  console.error(error);
  process.exitCode = 1;
}); 