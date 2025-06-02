import { initConfig } from "../../data/cryptoai";
import { CryptoAI } from "./cryptoAI";
const data = require("../../data/cryptoai/datajson/collections.json");

async function main(tokenId: any) {
  // if (process.env.NETWORK != "base_mainnet") {
  //     console.log("wrong network");
  //     return;
  // }

  let config = await initConfig();

  const dataContract = new CryptoAI(
    process.env.NETWORK,
    process.env.PRIVATE_KEY,
    process.env.PUBLIC_KEY
  );
  await dataContract.mint(
    tokenId,
    config.contractAddress,
    0,
    process.env.PUBLIC_KEY,
    // "0x3FA61d5C7C37efd91726cb970Ed6eB75870Da310",
    data[6].index[0],
    data[6].index[1]
  );
}

main(1).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
