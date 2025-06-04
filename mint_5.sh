#!/bin/bash


for i in {4000..4999}
do
  yarn ts:run scripts/nfts/cryptoai/5.mint.ts $i "0x8B61886dEFE41e5735FE47617c7e69e7D1fF2A75" "429c7c3b5ef132a9bcf872e0beecbe287d084c8ee780ba3e18cccc26e1ca0e8c"
done
