#!/bin/bash


for i in {1000..1999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x7e153A40d24Bf37DF3EC8Fb900157E3bCbaEA03d" "d4e4a6993ef50eb4af73a860628eb8f726e067afb0fd6cbcffd2f3f5ab5f0412"
done
