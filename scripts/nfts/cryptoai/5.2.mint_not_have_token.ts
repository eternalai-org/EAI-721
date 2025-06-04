import { initConfig } from "../../data/cryptoai";
import { CryptoAI } from "./cryptoAI";
const data = require("../../data/cryptoai/datajson/collections_nfs_be_id_not_found.json");

async function main(tokenId: any) {
  let config = await initConfig();


  const dataContract = new CryptoAI(
    process.env.NETWORK,
    "2c012ec5d7a41af63cc6ec8f4d3a68ec242c9171fec6345f660890039014e29f",
    "0x828Ee203A105530d8B755c22eB72Eb58CA8FF8e1"
  );
  
  const promises = data.map(async (item: any) => {

  console.log("Index:", item.index, "TokenId: ", item.token_id, "Address: ", "0x828Ee203A105530d8B755c22eB72Eb58CA8FF8e1");
  console.log(item.dna, item.elements);
    await dataContract.mint(
      config.contractAddress,
      0,
      item.token_id,
      "0x828Ee203A105530d8B755c22eB72Eb58CA8FF8e1",
      item.dna,
      item.elements
    );
  });
  await Promise.all(promises);
}

main(1).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
