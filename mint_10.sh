#!/bin/bash


for i in {9000..9999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x81A509A8069cC54B5d81fAf04d76C3a744e0F532"
done
