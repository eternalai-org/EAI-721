import { initConfig } from "../../data/cryptoai";
import { CryptoAI } from "./cryptoAI";

async function main() {
  let config = await initConfig();
  const args = process.argv.slice(2);

  try {
    const dataContract = new CryptoAI(
      process.env.NETWORK,
      process.env.PRIVATE_KEY,
      process.env.PUBLIC_KEY
    );

    // const data = require("../../data/cryptoai/datajson/collections.json");
    const data = require("../../data/cryptoai/datajson/collections_nfs_be.json");
    let index = 0;

    // const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
    // const waitForBlocks = async (blocks: number) => {
    //   const startBlock = await provider.getBlockNumber();
    //   while (await provider.getBlockNumber() < startBlock + blocks) {
    //     await new Promise(resolve => setTimeout(resolve, 1000));
    //   }
    // };

    if (args.length == 0) {
      for (const entry of data) {
        index++;
        await dataContract.mint(
          config.contractAddress,
          0,
          entry.token_id,
          process.env.PUBLIC_KEY,
          entry.data_mint[0],
          entry.data_mint[1]
        );
        console.log("index", index);
        // await waitForBlocks(1); // Wait for 1 block before minting the next NFT
      }
    } else {
      for (let i = 0; i <= parseInt(args[0]); i++) {
        await dataContract.mint(
          config.contractAddress,
          0,
          data[i].token_id,
          process.env.PUBLIC_KEY,
          data[i].data_mint[0],
          data[i].data_mint[1]
        );
        console.log("index", i);
        // await waitForBlocks(1); // Wait for 1 block before minting the next NFT
      }
    }
  } catch (error) {
    console.error("Error generating data:", error);
    process.exitCode = 1;
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});