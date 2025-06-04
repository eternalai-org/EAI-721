import * as fs from "fs";
const data = require("../../data/cryptoai/datajson/collections_nfs_be.json");

async function main() {
  // if (process.env.NETWORK != "local") {
  //     console.log("wrong network");
  //     return;
  // }
  let tokenIdsNotFound: number[] = [
    516, 517, 803, 813, 815, 820, 823, 827, 831, 1458, 1459, 1753, 1763, 1767,
    2526, 2527, 2820, 2825, 2828, 2832, 2836, 3129, 3130, 3143, 3144, 3534,
    3535, 3814, 3816, 3829, 3836, 3840, 4526, 4527, 4819, 4822, 4826, 4830,
    4834, 5527, 5528, 5821, 9834, 9824, 9528, 9527, 8838, 8828, 8826, 8806,
    8745, 8529, 8528, 7833, 7823, 7529, 7528, 7375, 6844, 6838, 6834, 6827,
    6824, 6822, 6802, 6662, 6528, 6527, 6012, 5836, 5832, 5828,
  ];

  let data_not_found: any[] = [];

  // let config = await initConfig();

  tokenIdsNotFound.map(async (item: any, index: number) => {
    const dataFromBe = data.find(
      (itemBe: any) => item === itemBe.token_id
    );
    data_not_found.push({
      token_id: item,
      dna: dataFromBe.data_mint[0],
      elements: dataFromBe.data_mint[1],
    });
  });

  // const dataContract = new CryptoAI(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
  // const promises = data.map(async (item: any, index: number) => {
  //     try {
  //         const data = await dataContract.tokenURI(config.contractAddress, item.token_id);
  //         if (!data) {
  //             tokenIdsNotFound.push({
  //                 index: index,
  //                 token_id: item.token_id,
  //                 dna: item.data_mint[0],
  //                 elements: item.data_mint[1],
  //             });
  //         }
  //     } catch (error) {
  //         console.log("Token not found", item.token_id);
  //         tokenIdsNotFound.push({
  //             index: index,
  //             token_id: item.token_id,
  //             dna: item.data_mint[0],
  //             elements: item.data_mint[1],
  //         });
  //     }
  // });

  await fs.writeFileSync(
    "scripts/data/cryptoai/datajson/collections_nfs_be_id_not_found.json",
    JSON.stringify(data_not_found, null, 2)
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
