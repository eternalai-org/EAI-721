#!/bin/bash


for i in {5999..5000}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x5e58bde648c28e2d7234702fa3ba38585cc629c9" "9e32dc958f3bb04d302a7dc8288e48cfdf32b3626da904cadf819bc706870f1c"
done
