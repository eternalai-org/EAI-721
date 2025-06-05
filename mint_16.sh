#!/bin/bash


for i in {4999..4000}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x6Fe4A03d014aE65f93543A1D4cF5217e0679c7c5" "2079fb61c99730d036edb908a63bb3b43f6295e37cf6999c8f75eeac0637004c"
done
