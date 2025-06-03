#!/bin/bash

yarn ts:run scripts/data/cryptoai/1.deploy.ts
yarn ts:run scripts/nfts/cryptoai/1.deploy.ts
yarn ts:run scripts/data/cryptoai/5.changeCryptoAiAddress.ts
yarn ts:run scripts/nfts/cryptoai/3.changeCryptoAiDataAddress.ts
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "PALETTE_COLOR"
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "TRAITS_DNA"
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Alien"
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Kong"
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "X-Type"
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Neo-Human"
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Robot"
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Collar"
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Head"
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Head_2"
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Mouth"
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Eyes"
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Earring"
yarn ts:run scripts/data/cryptoai/10.sealcontract.ts