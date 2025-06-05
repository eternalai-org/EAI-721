#!/bin/bash


for i in {8999..8000}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x78C9FFF450a3504c30314240916e04BA63B5617F" "57e38414f5f588d1c52a8aa433ad6265ac7ec137c9846743b5c0f345e0fc6358"
done
