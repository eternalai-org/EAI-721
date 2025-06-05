#!/bin/bash


for i in {2999..2000}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0xA2A8c9a4FC66ac83a430c027ebD156717342D923" "03f5f1259f4679665c8e556db3f2ff2b1082db3fbf3f781d1491f6f6b479bb86"
done
