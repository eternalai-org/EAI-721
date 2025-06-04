#!/bin/bash

# Mint script for collections_nfs_be_id_not_found.json
# Total items: 9357 (indices 0-9356)

for i in {0..9356}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint_not_found.ts $i "0x828Ee203A105530d8B755c22eB72Eb58CA8FF8e1" "2c012ec5d7a41af63cc6ec8f4d3a68ec242c9171fec6345f660890039014e29f"
done 