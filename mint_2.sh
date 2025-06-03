#!/bin/bash


for i in {1000..1999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x7e153A40d24Bf37DF3EC8Fb900157E3bCbaEA03d"
done
