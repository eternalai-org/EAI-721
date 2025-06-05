#!/bin/bash


for i in {7999..7000}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0xb44893517ae7fe7e3f77bcd39ddcc1f47b9900c9" "42a86bc540c5c726c45610e04b34b7d931cf8f8bd3c58efa2f2d1013161fb5c7"
done
