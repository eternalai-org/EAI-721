import { initConfig } from "../../data/cryptoai";
import { CryptoAI } from "./cryptoAI";

async function main() {
  if (process.env.NETWORK != "mainnet") {
    console.log("wrong network");
    return;
  }

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
  // Add address of user want to mint
  await dataContract.setFactory(
    config.contractAddress,
    0,
    "0x313FED7629F92c585A71C21Fe386638815C072E6"
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
