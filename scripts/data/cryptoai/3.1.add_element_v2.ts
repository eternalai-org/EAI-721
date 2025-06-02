import { CryptoAIData } from "./cryptoAIData";
import { DNA, ELEMENT, KEY_DNA, PALETTE_COLOR, TRAITS_DNA } from "./data";
import * as data from "./datajson/data-compressed.json";
import { initConfig } from "./index";

async function main() {
  if (process.env.NETWORK != "base_testnet") {
    console.log("wrong network");
    return;
  }
  const args = process.argv.slice(2) as string[];
  if (args.length == 0) {
    console.log("missing key");
  }
  const key = args[0];
  console.log("___key", key);

  try {
    let configaaa = await initConfig();

    const dataContract = new CryptoAIData(
      process.env.NETWORK,
      process.env.PRIVATE_KEY,
      process.env.PUBLIC_KEY
    );

    //ADD Element
    const address = configaaa["dataContractAddress"];

    // Check positions for each element
    data.elements.Mouth.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Mouth element - Name: ${data.elements.Mouth.names[index]}, Trait: ${data.elements.Mouth.traits[index]}`
        );
      }
    });

    data.elements.Collar.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Collar element - Name: ${data.elements.Collar.names[index]}, Trait: ${data.elements.Collar.traits[index]}`
        );
      }
    });

    data.elements.Eyes.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Eyes element - Name: ${data.elements.Eyes.names[index]}, Trait: ${data.elements.Eyes.traits[index]}`
        );
      }
    });

    data.elements.Head.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Head element - Name: ${data.elements.Head.names[index]}, Trait: ${data.elements.Head.traits[index]}`
        );
      }
    });

    data.elements.Earring.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Earring element - Name: ${data.elements.Earring.names[index]}, Trait: ${data.elements.Earring.traits[index]}`
        );
      }
    });
    // Check positions for each DNA variant
    data.DNA["Neo-Human"].positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Neo-Human DNA - Name: ${data.DNA["Neo-Human"].names[index]}, Trait: ${data.DNA["Neo-Human"].traits[index]}`
        );
      }
    });

    data.DNA["X-Type"].positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in X-Type DNA - Name: ${data.DNA["X-Type"].names[index]}, Trait: ${data.DNA["X-Type"].traits[index]}`
        );
      }
    });

    data.DNA.Alien.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Alien DNA - Name: ${data.DNA.Alien.names[index]}, Trait: ${data.DNA.Alien.traits[index]}`
        );
      }
    });

    data.DNA.Robot.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Robot DNA - Name: ${data.DNA.Robot.names[index]}, Trait: ${data.DNA.Robot.traits[index]}`
        );
      }
    });

    data.DNA.Kong.positions.forEach((pos: any[], index: number) => {
      if (pos.find((p) => p === null) === null) {
        throw new Error(
          `Null position found in Kong DNA - Name: ${data.DNA.Kong.names[index]}, Trait: ${data.DNA.Kong.traits[index]}`
        );
      }
    });

    switch (key) {
      case "PALETTE_COLOR":
        //Add palettes Color
        await dataContract.setPalettes(address, 0, PALETTE_COLOR);
        break;
      case "TRAITS_DNA":
        //ADD DNA
        await dataContract.addDNA(address, 0, KEY_DNA, TRAITS_DNA);
        break;
      case DNA.ALIEN:
        //Add DNA Variant
        await dataContract.addDNAVariant(
          address,
          0,
          DNA.ALIEN,
          data.DNA.Alien.names,
          data.DNA.Alien.traits,
          data.DNA.Alien.positions
        );
        break;
      case DNA.KONG:
        //Add DNA Variant
        await dataContract.addDNAVariant(
          address,
          0,
          DNA.KONG,
          data.DNA.Kong.names,
          data.DNA.Kong.traits,
          data.DNA.Kong.positions
        );
        break;
      case DNA.X_TYPE:
        //Add DNA Variant
        await dataContract.addDNAVariant(
          address,
          0,
          DNA.X_TYPE,
          data.DNA["X-Type"].names,
          data.DNA["X-Type"].traits,
          data.DNA["X-Type"].positions
        );
        break;
      case DNA.NEO_HUMAN:
        //Add DNA Variant
        await dataContract.addDNAVariant(
          address,
          0,
          DNA.NEO_HUMAN,
          data.DNA["Neo-Human"].names,
          data.DNA["Neo-Human"].traits,
          data.DNA["Neo-Human"].positions
        );
        break;
      case DNA.ROBOT:
        //Add DNA Variant
        await dataContract.addDNAVariant(
          address,
          0,
          DNA.ROBOT,
          data.DNA.Robot.names,
          data.DNA.Robot.traits,
          data.DNA.Robot.positions
        );
        break;
      case ELEMENT.COLLAR:
        //Add Element
        await dataContract.addItem(
          address,
          0,
          ELEMENT.COLLAR,
          data.elements.Collar.names,
          data.elements.Collar.traits,
          data.elements.Collar.positions
        );
        break;
      case ELEMENT.HEAD:
        // Add first half of Head elements
        {
          const mid = Math.ceil(data.elements.Head.names.length / 2);
          await dataContract.addMoreItem(
            address,
            0,
            ELEMENT.HEAD,
            data.elements.Head.names.slice(0, mid),
            data.elements.Head.traits.slice(0, mid),
            data.elements.Head.positions.slice(0, mid)
          );
        }
        break;
      case `${ELEMENT.HEAD}_2`:
        // Add second half of Head elements
        {
          const mid = Math.ceil(data.elements.Head.names.length / 2);
          await dataContract.addMoreItem(
            address,
            0,
            ELEMENT.HEAD,
            data.elements.Head.names.slice(mid),
            data.elements.Head.traits.slice(mid),
            data.elements.Head.positions.slice(mid)
          );
        }
        break;
      case ELEMENT.EYES:
        //Add Element
        await dataContract.addItem(
          address,
          0,
          ELEMENT.EYES,
          data.elements.Eyes.names,
          data.elements.Eyes.traits,
          data.elements.Eyes.positions
        );
        break;
      case ELEMENT.MOUTH:
        //Add Element
        await dataContract.addItem(
          address,
          0,
          ELEMENT.MOUTH,
          data.elements.Mouth.names,
          data.elements.Mouth.traits,
          data.elements.Mouth.positions
        );
      default:
        break;
      case ELEMENT.EARRING:
        //Add Element
        await dataContract.addItem(
          address,
          0,
          ELEMENT.EARRING,
          data.elements.Earring.names,
          data.elements.Earring.traits,
          data.elements.Earring.positions
        );
        break;
    }
  } catch (error) {
    console.log("Error checking positions:", error);
    throw error;
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
