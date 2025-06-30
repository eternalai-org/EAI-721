import { promises as fs } from "fs";

async function main() {
  const collections = require("./datajson/collections.json");

  const data: any[] = [];
  try {

  interface TraitData {
    counter: number;
  }
  const dataTraits: any = {};
  collections.forEach((collection: any) => {
  
    const dnaType = collection.name[1][0];
    if (!dataTraits[dnaType]) {
      dataTraits[dnaType] = {
        counter: 1
      };
    } else {
      dataTraits[dnaType].counter++;
    }
  });
    
   

    await fs.writeFile(
      "scripts/data/cryptoai/datajson/collections_dna_type_analytic.json",
      JSON.stringify(dataTraits, null, 2),
      "utf8"
    );
    console.log("Successfully wrote rarity data to collections_dna_type_analytic.json");
  } catch (error) {
    console.error("Error writing rarity data to file:", error);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
