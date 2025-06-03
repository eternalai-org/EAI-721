#!/bin/bash

yarn ts:run scripts/nfts/cryptoai/4.allowAdmin.ts "0x1D272FcA4EAdCc2d68072018A43cDdFfC00cADdE"

for i in {3000..3999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i
done
