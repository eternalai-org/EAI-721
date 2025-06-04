#!/bin/bash

for i in {0..999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x828Ee203A105530d8B755c22eB72Eb58CA8FF8e1" "2c012ec5d7a41af63cc6ec8f4d3a68ec242c9171fec6345f660890039014e29f"
  sleep 3
done
