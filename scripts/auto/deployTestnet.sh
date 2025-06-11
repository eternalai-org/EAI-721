#!/bin/bash

timeSleep=2.5


yarn ts:run scripts/data/cryptoai/1.deploy.ts
sleep $timeSleep
yarn ts:run scripts/nfts/cryptoai/1.deploy.ts
sleep $timeSleep
yarn ts:run scripts/data/cryptoai/5.changeCryptoAiAddress.ts
sleep $timeSleep
yarn ts:run scripts/nfts/cryptoai/3.changeCryptoAiDataAddress.ts
sleep $timeSleep
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "PALETTE_COLOR"
sleep $timeSleep
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "TRAITS_DNA" 
sleep $timeSleep
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Alien"
sleep $timeSleep
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Kong"
sleep $timeSleep
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "X-Type"
sleep $timeSleep
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Neo-Human"
sleep $timeSleep
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Robot"
sleep $timeSleep
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Collar"
sleep $timeSleep
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Head"
sleep $timeSleep
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Head_2"
sleep $timeSleep
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Mouth"
sleep $timeSleep
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Eyes"
sleep $timeSleep
yarn ts:run scripts/data/cryptoai/3.1.add_element_v2.ts "Earring"
sleep $timeSleep
yarn ts:run scripts/data/cryptoai/10.sealcontract.ts